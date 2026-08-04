{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.easyeffects ];

  home-manager.users.anthony = {
    # EasyEffects creates this entry when "Launch Service at System Startup" is enabled. Disable
    # that startup path so the ordered user service below is the only instance launched with the
    # graphical session.
    xdg.configFile."autostart/com.github.wwmm.easyeffects.desktop" = {
      force = true;
      text = ''
        [Desktop Entry]
        Name=Easy Effects
        Comment=Easy Effects Service
        Exec=easyeffects --hide-window --service-mode
        Icon=com.github.wwmm.easyeffects
        StartupNotify=false
        Terminal=false
        Type=Application
        Hidden=true
        X-GNOME-Autostart-Phase=Application
        X-KDE-autostart-phase=2
      '';
    };

    systemd.user.services.easyeffects = {
      Unit = {
        Description = "Easy Effects Service";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.easyeffects}/bin/easyeffects --hide-window --service-mode";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
