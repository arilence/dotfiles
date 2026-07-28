{ pkgs, ... }:

{
  home-manager.users.anthony.systemd.user.services.kopia-ui = {
    Unit = {
      Description = "Kopia backup UI";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStartPre = "${pkgs.glib}/bin/gdbus wait --session org.kde.StatusNotifierWatcher";
      ExecStart = "${pkgs.kopia-ui}/bin/kopia-ui";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
