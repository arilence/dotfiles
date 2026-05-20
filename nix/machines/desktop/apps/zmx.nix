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
          local __zmx_list
          __zmx_list="$(zmx list --short 2>/dev/null)"

          local -a __zmx_sessions
          __zmx_sessions=(''${(f)__zmx_list})

          local __zmx_name
          if (( ''${#__zmx_sessions} )); then
            __zmx_name="$(print -r -l -- "$__zmx_sessions[@]" | fzf --header 'choose zmx session' --prompt 'name: ' --bind 'enter:accept-or-print-query')"
          else
            __zmx_name="$(fzf --prompt 'zmx shell name: ' --bind 'enter:accept-or-print-query' < /dev/null)"
          fi

          local __zmx_status=$?
          if (( __zmx_status == 0 )); then
            [[ -n "$__zmx_name" ]] || __zmx_name=main
            exec zmx attach "$__zmx_name"
          fi
        }

        ts() {
          __zmx_attach_prompt
        }

        # Ask for the zmx session name when a terminal starts.
        if [[ $- == *i* ]] && [[ -z "$ZMX_SESSION" ]]; then
          __zmx_attach_prompt
        fi
      '';
    };
  };
}
