"""Event-driven Kitty titles and native sidebar rename for zmx sessions."""

import os

from zmx_session import SessionError, Sessions


def session_for_window(window):
    if not window:
        return ""
    if window.user_vars.get("zmx_managed") == "1":
        return window.user_vars.get("zmx_session", "")
    # Also recognize clients launched directly with native zmx attach.
    for process in window.child.foreground_processes:
        command = process.get("cmdline") or ()
        if (
            len(command) < 3
            or os.path.basename(command[0]) != "zmx"
            or command[1] not in ("a", "attach")
        ):
            continue
        args = iter(command[2:])
        for arg in args:
            if arg == "--labels":
                next(args, None)
            elif not arg.startswith("--labels="):
                pid = str(process["pid"])
                if window.user_vars.get("zmx_client_pid") != pid:
                    clear_native_metadata(window)
                    window.user_vars["zmx_client_pid"] = pid
                return window.user_vars.get("zmx_session") or (
                    window.child.foreground_environ.get("ZMX_SESSION_PREFIX", "") + arg
                )
    # Native attach has no helper to clear metadata on detach. Tie its cache
    # to the foreground client process, never to the lifetime of the pane.
    clear_native_metadata(window)
    return ""


def clear_native_metadata(window):
    for key in (
        "zmx_session",
        "zmx_session_id",
        "zmx_dir",
        "zmx_prefix",
        "zmx_title",
        "zmx_client_pid",
    ):
        window.user_vars.pop(key, None)


def sessions_for_window(window):
    env = dict(os.environ)
    env.update(window.child.foreground_environ)
    if directory := window.user_vars.get("zmx_dir"):
        env["ZMX_DIR"] = directory
    if "zmx_prefix" in window.user_vars:
        env["ZMX_SESSION_PREFIX"] = window.user_vars["zmx_prefix"]
    return Sessions(env)


def title_for_tab(data):
    from kitty.fast_data_types import get_boss

    tab = get_boss().tab_for_id(data.tab_id)
    window = tab.active_window if tab else None
    # While renaming, the ask overlay must not replace the session's title.
    if tab and tab.renaming_in_window == getattr(window, "id", None):
        window = get_boss().window_id_map.get(window.overlay_for)
    name = session_for_window(window)
    if name:
        if "zmx_session_id" not in window.user_vars:
            # Hydrate native attachments once, when first displayed. Subsequent
            # edits push OSC user vars; drawing the sidebar never polls labels.
            store = sessions_for_window(window)
            try:
                session = store.require(name)
                window.user_vars.update(store.metadata(session))
            except SessionError:
                return name
        return window.user_vars.get("zmx_title") or name
    return (tab.name if tab else "") or data.title


def on_set_user_var(boss, window, data):
    if data["key"] in ("zmx_session", "zmx_title", "zmx_dir"):
        if tab := window.tabref():
            tab.mark_tab_bar_dirty()


def install():
    from kitty.boss import Boss

    original = Boss.set_tab_title
    if getattr(original, "zmx_titles", False):
        return

    def set_tab_title(boss, title=None):
        tab = (
            boss.window_for_dispatch.tabref()
            if boss.window_for_dispatch
            else boss.active_tab
        )
        if not tab:
            return original(boss, title)
        if overlay := boss.window_id_map.get(tab.renaming_in_window):
            tab.set_active_window(overlay)
            return
        window = tab.active_window
        name = session_for_window(window)
        if not name:
            return original(boss, title)
        store = sessions_for_window(window)
        try:
            session = store.require(name)
        except SessionError as error:
            boss.show_error("Rename zmx session", str(error))
            return
        # Capture both the pane and session generation before an overlay can
        # change active_window or the user can focus a different split.
        window_id, tab_id, key = window.id, tab.id, session.key

        def commit(value):
            try:
                pane = boss.window_id_map.get(window_id)
                if not pane or session_for_window(pane) != name:
                    raise SessionError(
                        "The original pane has closed or switched sessions."
                    )
                store.rename(key, value, key=True)
            except (SessionError, OSError) as error:
                boss.show_error("Rename zmx session", str(error))

        if title is not None and title not in ('" "', "' '"):
            commit("" if title in ('""', "''") else title)
            return

        response = None

        def answered(result, target_window_id, current_boss):
            nonlocal response
            response = result.get("response")

        def removed(overlay_id, current_boss):
            if current_tab := boss.tab_for_id(tab_id):
                current_tab.renaming_in_window = 0
            # Native get_line() merges Escape and an empty submission. Retain
            # the raw ask result so Escape cancels and Enter on empty clears.
            if response is not None:
                commit(response)

        args = [
            "--type=line",
            "--message",
            "Rename zmx session (empty clears its title; Escape cancels)",
        ]
        if title is None:
            args.append("--default=" + session.display)
        overlay = boss.run_kitten_with_metadata(
            "ask",
            args,
            window=window,
            custom_callback=answered,
            default_data={"response": None},
            action_on_removal=removed,
        )
        if overlay is not None:
            tab.renaming_in_window = overlay.id

    set_tab_title.zmx_titles = True
    Boss.set_tab_title = set_tab_title
