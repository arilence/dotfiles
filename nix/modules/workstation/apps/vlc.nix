{ lib, pkgs, ... }:

let
  vlcWayland = pkgs.symlinkJoin {
    name = "${pkgs.vlc.name}-wayland";
    paths = [ pkgs.vlc ];
    nativeBuildInputs = [ pkgs.makeWrapper ];

    postBuild = ''
      # Force VLC to use Wayland so drag and drop works within Niri's desktop environment
      wrapProgram $out/bin/vlc \
        --unset DISPLAY \
        --set QT_QPA_PLATFORM wayland

      # VLC's desktop entry uses the package's absolute store path, so point launchers and "Open
      # With" actions at the Wayland wrapper as well.
      rm $out/share/applications/vlc.desktop
      cp ${pkgs.vlc}/share/applications/vlc.desktop $out/share/applications/vlc.desktop
      substituteInPlace $out/share/applications/vlc.desktop \
        --replace-fail ${lib.getExe pkgs.vlc} $out/bin/vlc
    '';
  };
in
{
  environment.systemPackages = [ vlcWayland ];
}
