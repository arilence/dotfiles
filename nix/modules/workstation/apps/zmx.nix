{
  lib,
  pkgs,
  ...
}:

let
  zmx = pkgs.nixosUnstable.zmx;

  zmx-kill-all-worker = pkgs.writeShellApplication {
    name = "zmx-kill-all-worker";
    runtimeInputs = [ zmx ];
    text = ''
      while IFS= read -r session; do
        zmx kill "$session"
      done < <(zmx list --short)
    '';
  };

  zmx-kill-all = pkgs.writeShellApplication {
    name = "zmx-kill-all";
    runtimeInputs = [
      pkgs.systemd
      zmx
    ];
    text = ''
      sessions=$(zmx list --short)

      if [[ -z "$sessions" ]]; then
        echo "No active zmx sessions."
        exit 0
      fi

      echo "The following zmx sessions will be killed:"
      printf '  %s\n' "$sessions"
      printf 'Continue? [y/N] '
      IFS= read -r reply || true

      case "$reply" in
        y | Y | yes | YES | Yes) ;;
        *)
          echo "Cancelled."
          exit 0
          ;;
      esac

      systemd-run \
        --user \
        --unit=zmx-kill-all \
        --collect \
        --quiet \
        --setenv=ZMX_SESSION= \
        ${zmx-kill-all-worker}/bin/zmx-kill-all-worker

      echo "Killing all zmx sessions outside the zmx process tree."
    '';
  };
in
{
  environment.systemPackages = [
    zmx
    zmx-kill-all
    pkgs.fzf
  ];

  home-manager.users.anthony = {
    programs.zsh = {
      shellAliases = {
        t = "zmx";
        ta = "zmx attach";
        tl = "zmx list";
        tk = "zmx kill";
        tkall = "zmx-kill-all";
      };

      initContent = lib.mkOrder 1500 ''
        __zmx_attach_prompt() {
          local display
          display=$(zmx list 2>/dev/null | awk -F '\t' '
            {
              name = pid = clients = dir = ""
              for (i = 1; i <= NF; i++) {
                field = $i
                sub(/^[^[:alpha:]_]*/, "", field)
                key = value = field
                sub(/=.*/, "", key)
                sub(/^[^=]*=/, "", value)

                if (key == "name" || key == "session_name") name = value
                else if (key == "pid") pid = value
                else if (key == "clients") clients = value
                else if (key == "start_dir" || key == "started_in") dir = value
              }

              if (name != "") {
                if (pid ~ /^[[:digit:]]+$/) {
                  command = "readlink -- /proc/" pid "/cwd 2>/dev/null"
                  # Display the current directory instead of the starting directory
                  if ((command | getline current_dir) > 0) dir = current_dir
                  close(command)
                }

                printf "%-20s  clients:%-2s  %s\n", name, clients, dir
              }
            }
          ')

          local output query key selected session_name
          output=$({ [[ -n "$display" ]] && printf '%s\n' "$display"; } | fzf \
            --nth=1 \
            --print-query \
            --expect=ctrl-n \
            --layout=default \
            --border=rounded \
            --margin=8%,10% \
            --padding=1,2 \
            --prompt="zmx> " \
            --header="Enter: select | Ctrl-N: create new" \
            --preview='zmx history {1}' \
            --preview-window=right:60%:follow \
          )
          local rc=$?

          query=$(printf '%s\n' "$output" | sed -n '1p')
          key=$(printf '%s\n' "$output" | sed -n '2p')
          selected=$(printf '%s\n' "$output" | sed -n '3p')

          if [[ "$key" == "ctrl-n" && -n "$query" ]]; then
            session_name="$query"
          elif [[ $rc -eq 0 && -n "$selected" ]]; then
            session_name=$(printf '%s\n' "$selected" | awk '{print $1}')
          elif [[ -n "$query" ]]; then
            session_name="$query"
          else
            return 130
          fi

          zmx attach "$session_name"
        }

        ts() {
          __zmx_attach_prompt
        }

        # Launch a named zmx session in a new kitty tab.
        # Swap to it if the name already exists.
        kzmx() {
          if (( $# < 1 || $# > 3 )); then
            printf 'usage: kzmx <zmx-session> [cwd]\n       kzmx <zmx-session> <tab-title> <cwd>\n' >&2
            return 2
          fi

          local session_name="$1"
          local tab_title="$session_name"
          local cwd="$PWD"
          if (( $# == 2 )); then
            cwd="$2"
          elif (( $# == 3 )); then
            tab_title="$2"
            cwd="$3"
          fi
          local session_id
          session_id=$(printf '%s' "$session_name" | sha256sum | awk '{print $1}')

          kitten @ focus-tab --match "var:zmx_session_id=$session_id" 2>/dev/null \
            || kitten @ launch \
              --type=tab \
              --tab-title "$tab_title" \
              --cwd "$cwd" \
              --env ZMX_AUTO_ATTACH=0 \
              --var "zmx_session=$session_name" \
              --var "zmx_session_id=$session_id" \
              zmx attach "$session_name"
        }

        dev() {
          if (( $# != 1 )); then
            printf 'usage: dev <directory-name>\n' >&2
            return 2
          fi

          local name="$1"
          local cwd
          cwd=$(zoxide query -- "$name") || {
            printf 'dev: no directory found for %q\n' "$name" >&2
            return 1
          }

          kzmx "$name.vim" "$cwd"
          kzmx "$name.zsh" "$cwd"
          kzmx "$name.git" "$cwd"
        }

        # Ask for the zmx session name only when the terminal explicitly opts in.
        if command -v zmx &> /dev/null \
          && command -v fzf &> /dev/null \
          && [[ -z "$ZMX_SESSION" && "''${ZMX_AUTO_ATTACH:-0}" == 1 ]]; then
          __zmx_attach_prompt && exit
        fi
      '';
    };
  };
}
