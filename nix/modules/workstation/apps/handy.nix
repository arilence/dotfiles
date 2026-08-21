{
  lib,
  pkgs,
  ...
}:

let
  handy = pkgs.nixosUnstable.handy;

  handyToggle = pkgs.writeShellApplication {
    name = "handy-toggle";
    runtimeInputs = [ pkgs.procps ];
    text = ''
      # Nix runs Handy as .handy-wrapped, so an exact process-name match will fail.
      exec pkill -USR2 -n handy
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
        ExecStartPre = "${pkgs.glib}/bin/gdbus wait --session org.kde.StatusNotifierWatcher";
        ExecStart = "${handy}/bin/handy --start-hidden";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
