{
  lib,
  pkgs,
  ...
}:

let
  zmx = pkgs.nixosUnstable.zmx;

  zmx-session = import ./zmx { inherit pkgs; };

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
      ${zmx-session}/bin/zmx-session list
      printf 'Continue? [y/N] '
      IFS= read -r -n 1 reply || true
      printf '\n'

      case "$reply" in
        y | Y) ;;
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
    zmx-session
    zmx-kill-all
    pkgs.fzf
  ];

  home-manager.users.anthony = {
    programs.zsh = {
      shellAliases = {
        t = "zmx";
        ta = "zmx-session attach";
        zmx-title = "zmx-session rename";
        tl = "ts";
        tkall = "zmx-kill-all";
      };

      initContent = lib.mkOrder 1500 ''
        # Keep selection tokens separate from displayed titles. Every action
        # resolves and validates through the shared session module.
        __zmx_attach_prompt() {
          local display
          display=$(zmx-session rows) || return

          local output query key selected
          output=$({ [[ -n "$display" ]] && printf '%s\n' "$display"; } | fzf \
            --delimiter=$'\t' \
            --with-nth=2.. \
            --nth=1 \
            --print-query \
            --expect=ctrl-n \
            --bind='ctrl-x:execute-silent(zmx-session kill-key {1})+reload(zmx-session rows)' \
            --bind='ctrl-r:execute(zmx-session rename --key --session {1})+reload(zmx-session rows)' \
            --bind='tab:transform-query(printf "%s" {2})+end-of-line' \
            --bind='focus:show-preview' \
            --bind='zero:hide-preview' \
            --height=100% \
            --layout=reverse \
            --highlight-line \
            --border=top \
            --border-label=" Enter or select a zmx session " \
            --border-label-pos=2 \
            --prompt="zmx> " \
            --header="Enter: select | Tab: complete title | Ctrl-N: create | Ctrl-R: rename | Ctrl-X: kill" \
            --preview='zmx-session history-key {1}' \
            --preview-label=" Session preview " \
            --preview-label-pos=2 \
            --preview-window='right:60%:follow:hidden:<80(down:60%:follow:hidden)' \
          )
          local rc=$?
          (( rc == 0 || rc == 1 )) || return "$rc"

          query=$(printf '%s\n' "$output" | sed -n '1p')
          key=$(printf '%s\n' "$output" | sed -n '2p')
          selected=$(printf '%s\n' "$output" | sed -n '3p')

          if [[ "$key" == "ctrl-n" && -n "$query" ]]; then
            zmx-session attach --new -- "$query"
          elif [[ -n "$selected" ]]; then
            zmx-session attach-key "''${selected%%$'\t'*}"
          elif [[ -n "$query" ]]; then
            zmx-session attach -- "$query"
          else
            return 130
          fi
        }

        ts() {
          __zmx_attach_prompt
        }

        # Launch/focus by title or internal ID. New sessions get a generated ID.
        kzmx() {
          if (( $# < 1 || $# > 2 )); then
            printf 'usage: kzmx <title-or-id> [cwd]\n' >&2
            return 2
          fi
          local name="$1" cwd="$PWD"
          if (( $# == 2 )); then
            cwd="$2"
          fi
          zmx-session launch --cwd "$cwd" -- "$name"
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
