{ pkgs, ... }:

let
  e = pkgs.writeShellApplication {
    name = "e";
    text = ''
      usage() {
        echo "Usage: $0 <location>" >&2
        echo "  <location>: optionally open the specified file/directory in your editor" >&2
        echo "  otherwise opens the current directory in your editor" >&2
        exit 1
      }

      if [[ "''${1:-}" == "help" || "''${1:-}" == "-h" || "''${1:-}" == "--help" ]]; then
        usage
      fi

      exec "$EDITOR" "''${1:-.}"
    '';
  };

  yt-audio-tracks = pkgs.writeShellApplication {
    name = "yt-audio-tracks";
    runtimeInputs = with pkgs; [
      ffmpeg
      yt-dlp
    ];
    text = ''
      usage() {
        echo "Usage: $0 <youtube-url>" >&2
        echo "  Downloads a YouTube video as split audio tracks into the current directory." >&2
        exit 1
      }

      if [[ "$#" -ne 1 || "''${1:-}" == "help" || "''${1:-}" == "-h" || "''${1:-}" == "--help" ]]; then
        usage
      fi

      yt-dlp \
        -f "bestaudio/best" \
        -x --audio-format best \
        --split-chapters \
        --no-embed-thumbnail \
        --write-thumbnail \
        --write-info-json \
        --write-description \
        --embed-metadata \
        -o "%(title).200B [%(id)s].%(ext)s" \
        -o "chapter:%(section_number)02d - %(section_title).200B.%(ext)s" \
        "$1"
    '';
  };

  diff-remote = pkgs.writeTextFile {
    name = "diff-remote";
    destination = "/bin/diff-remote";
    executable = true;
    text = ''
      #!${pkgs.zsh}/bin/zsh

      set -euo pipefail

      usage() {
        local exit_status
        exit_status="$1"

        cat >&2 <<'USAGE'
      Usage:
        diff-remote [diff-option ...] <local-file> <user@host>:<remote-file>
        diff-remote [diff-option ...] <local-file> <user@host> <remote-file>

      Examples:
        diff-remote ./configuration.nix anthony@server:/etc/nixos/configuration.nix
        diff-remote --color=always ./app.conf root@server /etc/app.conf

      Runs diff -u against a remote file fetched over:
        ssh -n -o BatchMode=yes <user@host> 'cat <remote-file>'
      USAGE
        exit "$exit_status"
      }

      die() {
        echo "diff-remote: $*" >&2
        exit 2
      }

      diff_args=(-u)

      while [[ $# -gt 0 ]]; do
        case "$1" in
          help|-h|--help)
            usage 0
            ;;
          --)
            shift
            break
            ;;
          -*)
            diff_args+=("$1")
            shift
            ;;
          *)
            break
            ;;
        esac
      done

      [[ $# -eq 2 || $# -eq 3 ]] || usage 1

      local_file="$1"
      remote_host=""
      remote_file=""

      if [[ $# -eq 2 ]]; then
        remote_spec="$2"
        [[ "$remote_spec" == *:* ]] || die "remote target must look like <user@host>:<remote-file>"

        remote_host="''${remote_spec%%:*}"
        remote_file="''${remote_spec#*:}"
      else
        remote_host="$2"
        remote_file="$3"
      fi

      [[ -n "$remote_host" ]] || die "remote host is empty"
      [[ -n "$remote_file" ]] || die "remote file is empty"
      [[ -r "$local_file" ]] || die "local file is not readable: $local_file"

      tmp_file="$(${pkgs.coreutils}/bin/mktemp -t diff-remote.XXXXXXXXXX)"
      cleanup() {
        ${pkgs.coreutils}/bin/rm -f -- "$tmp_file"
      }
      trap cleanup EXIT

      quoted_remote_file="''${(q)remote_file}"
      if ! ${pkgs.openssh}/bin/ssh -n -o BatchMode=yes "$remote_host" "cat -- $quoted_remote_file" > "$tmp_file"; then
        die "failed to read remote file: $remote_host:$remote_file"
      fi

      ${pkgs.diffutils}/bin/diff \
        "''${diff_args[@]}" \
        --label "$local_file" \
        --label "$remote_host:$remote_file" \
        "$local_file" \
        "$tmp_file"
    '';
  };
in
{
  home-manager.users.anthony.home.packages = [
    diff-remote
    e
    yt-audio-tracks
  ];
}
