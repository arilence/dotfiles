"""Session identity and title policy shared by the CLI and Kitty integration."""

import argparse
import base64
from contextlib import contextmanager
from dataclasses import dataclass, replace
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import time
from urllib.parse import unquote, urlsplit

ZMX = "@zmx@"
KITTEN = "@kitten@"


class SessionError(Exception):
    pass


@dataclass(frozen=True)
class Session:
    name: str
    title: str = ""
    pid: str = ""
    created: str = ""
    clients: str = "0"
    cwd: str = ""

    @property
    def display(self):
        return self.title or self.name

    @property
    def key(self):
        # Picker actions receive a shell-safe token, never a displayed name.
        data = json.dumps([self.name, self.pid, self.created]).encode()
        return base64.urlsafe_b64encode(data).decode()


class Sessions:
    def __init__(self, env=None):
        self.env = dict(os.environ if env is None else env)
        if "ZMX_DIR" in self.env:
            self.directory = self.env["ZMX_DIR"]
        elif "XDG_RUNTIME_DIR" in self.env:
            self.directory = self.env["XDG_RUNTIME_DIR"] + "/zmx"
        else:
            self.directory = (
                self.env.get("TMPDIR", "/tmp").rstrip("/") + f"/zmx-{os.getuid()}"
            )
        self.prefix = self.env.get("ZMX_SESSION_PREFIX", "")
        # Names returned by zmx list and ZMX_SESSION already include the prefix.
        self.native_env = self.env.copy()
        self.native_env.pop("ZMX_SESSION_PREFIX", None)

    def run(self, *args):
        try:
            result = subprocess.run(
                [ZMX, *args],
                env=self.native_env,
                capture_output=True,
                text=True,
                timeout=10,
            )
        except (OSError, subprocess.TimeoutExpired) as error:
            raise SessionError(f"zmx {args[0]}: {error}") from error
        if result.returncode:
            raise SessionError(result.stderr.strip() or f"zmx {args[0]} failed")
        return result.stdout

    @contextmanager
    def locked(self):
        Path(self.directory).mkdir(mode=0o750, parents=True, exist_ok=True)
        # This file holds only a lock; titles live exclusively in zmx labels.
        with open(Path(self.directory) / ".titles.lock", "a") as lock:
            fcntl.flock(lock, fcntl.LOCK_EX)
            yield

    def list(self):
        sessions = []
        for line in self.run("list").splitlines():
            fields = dict(
                field.split("=", 1) for field in line.split("\t") if "=" in field
            )
            # Native list decorates only its first field with a current marker.
            first = line.split("\t", 1)[0]
            name = first.partition("name=")[2]
            if not name:
                continue
            if "err" in fields:
                if fields.get("status") == "cleaning up":
                    continue
                raise SessionError(f"Cannot check session {name!r}: {fields['err']}")
            cwd = fields.get("cwd", "")
            if cwd.startswith("file://"):
                cwd = unquote(urlsplit(cwd).path)
            sessions.append(
                Session(
                    name,
                    fields.get("title", ""),
                    fields.get("pid", ""),
                    fields.get("created", ""),
                    fields.get("clients", "0"),
                    cwd,
                )
            )
        return sessions

    def resolve(self, query, sessions=None):
        if query == ".":
            query = self.env.get("ZMX_SESSION", "")
            if not query:
                raise SessionError("Run inside a zmx session or specify --session.")
        if not query:
            return None
        sessions = self.list() if sessions is None else sessions
        matches = [
            s
            for s in sessions
            if query in (s.name, s.title) or self.prefix + query == s.name
        ]
        if len(matches) > 1:
            raise SessionError(f"Ambiguous session name or title: {query!r}")
        return matches[0] if matches else None

    def require(self, query):
        session = self.resolve(query)
        if session is None:
            raise SessionError(f"Session not found: {query!r}")
        return session

    def from_key(self, key):
        try:
            name, pid, created = json.loads(base64.urlsafe_b64decode(key))
        except (ValueError, TypeError) as error:
            raise SessionError("Invalid session selection.") from error
        session = self.require(name)
        if (session.pid, session.created) != (pid, created):
            raise SessionError(
                "The selected session has exited. Select a session again."
            )
        return session

    def validate(self, value):
        if not re.fullmatch(r"[A-Za-z0-9._-]+", value) or value in (".", ".."):
            raise SessionError(
                "Use ASCII letters, digits, '-', '_', or '.'; '.' and '..' are reserved."
            )
        # Linux sockaddr_un has 107 usable bytes. Match zmx's literal path math.
        maximum = (
            107 - len(os.fsencode(self.directory)) - 1 - len(os.fsencode(self.prefix))
        )
        if len(value.encode()) > maximum:
            raise SessionError(f"Name/title is too long (maximum {maximum} bytes).")

    @staticmethod
    def available(value, sessions, owner=None):
        for session in sessions:
            if session.name != owner and value in (session.name, session.title):
                raise SessionError(
                    f"Name/title {value!r} is already reserved by {session.display!r}."
                )

    def ensure(self, name, *, cwd=None, new=False, existing=False, key=False):
        with self.locked():
            if key:
                return self.from_key(name)
            sessions = self.list()
            session = self.resolve(name, sessions)
            if session:
                if new:
                    raise SessionError(f"Name/title {name!r} is already in use.")
                return session
            if existing or name == ".":
                raise SessionError(f"Session not found: {name!r}")
            self.validate(name)
            self.available(name, sessions)
            reserved = {
                value for session in sessions for value in (session.name, session.title)
            }
            timestamp = str(int(time.time()))
            generated = timestamp
            suffix = 2
            while self.prefix + generated in reserved:
                generated = f"{timestamp}-{suffix}"
                suffix += 1
            self.validate(generated)
            internal = self.prefix + generated
            env = self.env.copy()
            env.pop("ZMX_SESSION", None)
            # EOF detaches this initial client. The normal login shell survives.
            # subprocess closes the lock FD before spawning the daemon.
            result = subprocess.run(
                [ZMX, "attach", "--labels", f"title={name}", generated],
                env=env,
                cwd=cwd,
                stdin=subprocess.DEVNULL,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.PIPE,
                text=True,
                timeout=10,
            )
            if result.returncode:
                raise SessionError(result.stderr.strip() or "Could not create session.")
            session = self.require(internal)
            if session.title != name:
                raise SessionError(
                    "Session was created but its title could not be verified."
                )
            return session

    def _rename(self, session, title, sessions):
        if title:
            self.validate(title)
            self.available(title, sessions, owner=session.name)
        self.run("set", session.name, f"title={title}")
        updated = replace(session, title=title)
        self.publish(updated)
        return updated

    def rename(self, query, title, *, key=False):
        with self.locked():
            session = self.from_key(query) if key else self.require(query)
            return self._rename(session, title, self.list())

    def metadata(self, session):
        identity = f"{self.directory}\0{session.name}"
        return {
            "zmx_session": session.name,
            "zmx_session_id": hashlib.sha256(identity.encode()).hexdigest(),
            "zmx_dir": self.directory,
            "zmx_prefix": self.prefix,
            "zmx_title": session.title,
        }

    def publish(self, session):
        # Broadcast only the changed title; attachment metadata stays local.
        title = base64.b64encode(session.title.encode()).decode()
        self.run("print", session.name, f"\x1b]1337;SetUserVar=zmx_title={title}\x07")

    def pane_target(self):
        address = self.env.get("KITTY_LISTEN_ON", "")
        window = self.env.get("KITTY_WINDOW_ID", "")
        if current := self.env.get("ZMX_SESSION"):
            # Session environments can retain the first client's Kitty IDs.
            address = (
                self.run("print-env", current, "KITTY_LISTEN_ON").strip() or address
            )
            window = self.run("print-env", current, "KITTY_WINDOW_ID").strip() or window
        return address, window

    def set_pane(self, target, session):
        address, window = target
        if not address or not window:
            return
        values = (
            self.metadata(session)
            if session
            else dict.fromkeys(
                (
                    "zmx_session",
                    "zmx_session_id",
                    "zmx_dir",
                    "zmx_prefix",
                    "zmx_title",
                    "zmx_managed",
                    "zmx_client_pid",
                ),
                None,
            )
        )
        if session and not self.env.get("ZMX_SESSION"):
            values["zmx_managed"] = "1"
        args = [
            key if value is None else f"{key}={value}" for key, value in values.items()
        ]
        result = subprocess.run(
            [
                KITTEN,
                "@",
                "--to",
                address,
                "set-user-vars",
                "--match",
                f"id:{window}",
                *args,
            ],
            capture_output=True,
            text=True,
            timeout=5,
        )
        if result.returncode:
            print(
                f"zmx-session: could not update Kitty: {result.stderr.strip()}",
                file=sys.stderr,
            )

    def attach(self, name, **options):
        session = self.ensure(name, **options)
        target = self.pane_target()
        result = 1
        try:
            self.set_pane(target, session)
            result = subprocess.call([ZMX, "attach", session.name], env=self.native_env)
            return result
        finally:
            if not self.env.get("ZMX_SESSION"):
                self.set_pane(target, None)
            elif result:
                self.set_pane(target, self.require("."))

    def launch(self, name, *, cwd=None):
        session = self.ensure(name, cwd=cwd)
        args = [KITTEN, "@"]
        if address := self.pane_target()[0]:
            args.extend(["--to", address])
        focused = subprocess.run(
            [
                *args,
                "focus-tab",
                "--match",
                f"var:zmx_session_id={self.metadata(session)['zmx_session_id']}",
            ],
            capture_output=True,
            timeout=5,
        )
        if focused.returncode:
            command = [
                *args,
                "launch",
                "--type=tab",
                "--cwd",
                cwd or os.getcwd(),
                "--env",
                "ZMX_AUTO_ATTACH=0",
                "--env",
                "ZMX_SESSION=",
                "--env",
                f"ZMX_DIR={self.directory}",
                "--env",
                f"ZMX_SESSION_PREFIX={self.prefix}",
            ]
            for key, value in self.metadata(session).items():
                command.extend(["--var", f"{key}={value}"])
            command.extend(["--var", "zmx_managed=1"])
            command.extend(
                [
                    sys.executable,
                    str(Path(__file__).resolve()),
                    "attach",
                    "--existing",
                    "--",
                    session.name,
                ]
            )
            return subprocess.call(command)
        return 0

    def display(self, name):
        # Used by Starship: one label read, no registry or stale exported title.
        if name == ".":
            name = self.env.get("ZMX_SESSION", "")
        if not name:
            return ""
        labels = dict(
            pair.split("=", 1) for pair in self.run("get", name).split() if "=" in pair
        )
        return labels.get("title") or name


def clean_display(value):
    return "".join(char if char.isprintable() else " " for char in value)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    for command in ("attach", "launch"):
        sub = commands.add_parser(command)
        sub.add_argument("--cwd")
        if command != "launch":
            sub.add_argument("--new", action="store_true")
            sub.add_argument("--existing", action="store_true")
        sub.add_argument("name")
    commands.add_parser("list")
    commands.add_parser("rows")
    sub = commands.add_parser("display")
    sub.add_argument("name", nargs="?", default=".")
    sub = commands.add_parser("rename")
    sub.add_argument("--session", default=".")
    sub.add_argument("--key", action="store_true")
    sub.add_argument("title", nargs="?")
    for command in ("attach-key", "kill-key", "history-key"):
        commands.add_parser(command).add_argument("key")
    args = vars(parser.parse_args())
    command = args.pop("command")
    store = Sessions()
    try:
        if command in ("attach", "launch"):
            return getattr(store, command)(**args)
        if command == "display":
            print(store.display(args["name"]), end="")
        elif command in ("list", "rows"):
            for session in store.list():
                display = clean_display(session.display)
                cwd = clean_display(session.cwd)
                if command == "rows":
                    print(f"{session.key}\t{display}\tclients:{session.clients}\t{cwd}")
                else:
                    print(f"{display:20}  clients:{session.clients:<2}  {cwd}")
        elif command == "rename":
            query = args["session"]
            session = store.from_key(query) if args["key"] else store.require(query)
            title = args["title"]
            while True:
                interactive = title is None
                if interactive:
                    print(
                        f"Title for {session.display} (empty clears; Escape cancels):",
                        file=sys.stderr,
                    )
                    # Zsh vared gives the shell and fzf action one prefilled editor.
                    editor = subprocess.run(
                        [
                            "zsh",
                            "-fc",
                            "bindkey -e; cancel_title() { exit 130; }; "
                            'zle -N cancel_title; bindkey "^[" cancel_title; '
                            'bindkey "^C" cancel_title; title=$1; '
                            'vared -p "title> " title || exit 130; '
                            'printf "%s" "$title"',
                            "zmx-title",
                            session.display,
                        ],
                        stdout=subprocess.PIPE,
                        text=True,
                    )
                    if editor.returncode:
                        return editor.returncode
                    title = editor.stdout
                try:
                    store.rename(session.key, title, key=True)
                    break
                except SessionError as error:
                    if not interactive:
                        raise
                    print(str(error), file=sys.stderr)
                    title = None
        elif command.endswith("-key"):
            if command == "attach-key":
                return store.attach(args["key"], key=True)
            session = store.from_key(args["key"])
            if command == "history-key":
                sys.stdout.write(store.run("history", session.name))
            else:
                with store.locked():
                    session = store.from_key(args["key"])
                    store.run("kill", session.name)
        return 0
    except (SessionError, OSError, subprocess.TimeoutExpired) as error:
        print(f"zmx-session: {error}", file=sys.stderr)
        return 1
    except KeyboardInterrupt:
        return 130


if __name__ == "__main__":
    sys.exit(main())
