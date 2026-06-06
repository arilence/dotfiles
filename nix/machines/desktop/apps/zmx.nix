{
  inputs,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = [
    inputs.zmx.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.fzf
  ];

  home-manager.users.anthony = {
    programs.zsh = {
      shellAliases = {
        t = "zmx";
        ta = "zmx attach";
        tl = "zmx list";
        tk = "zmx kill";
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
                printf "%-20s  pid:%-8s  clients:%-2s  %s\n", name, pid, clients, dir
              }
            }
          ')

          local output query key selected session_name
          output=$({ [[ -n "$display" ]] && printf '%s\n' "$display"; } | fzf \
            --print-query \
            --expect=ctrl-n \
            --height=80% \
            --reverse \
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

        # Ask for the zmx session name when a terminal starts.
        if command -v zmx &> /dev/null && command -v fzf &> /dev/null && [[ -z "$ZMX_SESSION" ]]; then
          __zmx_attach_prompt && exit
        fi
      '';
    };
  };
}
