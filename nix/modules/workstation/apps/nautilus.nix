{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.nautilus ];

  home-manager.users.anthony =
    { config, ... }:
    {
      # These bookmarks appear in the Nautilus sidebar.
      xdg.configFile."gtk-3.0/bookmarks".force = true;
      gtk = {
        enable = true;
        gtk3.bookmarks = [
          "file://${config.home.homeDirectory}/code Code"
          "file://${config.xdg.userDirs.desktop}"
          "file://${config.xdg.userDirs.documents}"
          "file://${config.xdg.userDirs.download}"
          "file://${config.xdg.userDirs.pictures}"
          "file://${config.xdg.userDirs.music}"
          "smb://10.0.10.10/files/ NAS Files"
          "smb://10.0.10.10/media/ NAS Media"
        ];
      };

      xdg.mimeApps.defaultApplications."inode/directory" = "org.gnome.Nautilus.desktop";
    };
}
