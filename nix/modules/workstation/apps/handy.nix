{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.arilence.workstation.apps.handy;
  handy = pkgs.nixpkgsUnstable.handy;

  handyToggle = pkgs.writeShellApplication {
    name = "handy-toggle";
    runtimeInputs = [ handy ];
    text = ''
      exec handy --toggle-transcription
    '';
  };
in
{
  options.arilence.workstation.apps.handy.autoStart =
    lib.mkEnableOption "starting Handy with the graphical session";

  config = {
    environment.systemPackages = [
      handy
      handyToggle
      pkgs.wtype
    ];

    home-manager.users.anthony.systemd.user.services.handy = {
      Unit = {
        Description = "Handy speech-to-text";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${handy}/bin/handy --start-hidden";
        Restart = "on-failure";
        RestartSec = 5;
      };

      Install.WantedBy = lib.optionals cfg.autoStart [ "graphical-session.target" ];
    };
  };
}
