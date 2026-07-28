{ pkgs, ... }:

{
  home-manager.users.anthony.systemd.user.services."1password" = {
    Unit = {
      Description = "1Password";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "simple";
      ExecStartPre = "${pkgs.glib}/bin/gdbus wait --session org.kde.StatusNotifierWatcher";
      ExecStart = "${pkgs._1password-gui}/bin/1password --silent";
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
