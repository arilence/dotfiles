{
  inputs,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = [
    inputs.zmx.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  home-manager.users.anthony = {
    programs.zsh = {
      shellAliases = {
        t = "zmx";
        ta = "zmx attach";
        tl = "zmx list";
        tk = "zmx kill";
      };

      # Autostart a zmx session called "main" when terminal starts.
      # If already in use, create a new session "main.N" where N incremented by 1
      initContent = lib.mkOrder 1500 ''
        if [[ $- == *i* ]] && [[ -z "$ZMX_SESSION" ]]; then
          local -a __zmx_sessions
          __zmx_sessions=("''${(@f)$(zmx list --short 2>/dev/null)}")
          local __zmx_name=main
          if (( ''${__zmx_sessions[(Ie)main]} )); then
            local __zmx_n=1
            while (( ''${__zmx_sessions[(Ie)main.$__zmx_n]} )); do
              (( __zmx_n++ ))
            done
            __zmx_name="main.$__zmx_n"
          fi
          exec zmx attach "$__zmx_name"
        fi
      '';
    };
  };
}
