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
      ExecStart = "${pkgs._1password-gui}/bin/1password --silent";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
