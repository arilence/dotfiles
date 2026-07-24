{ pkgs, ... }:

let
  moonlightDesktop = pkgs.makeDesktopItem {
    name = "com.moonlight_stream.Moonlight";
    desktopName = "Moonlight";
    comment = "Stream games and other applications from another PC running Sunshine or GeForce Experience";
    exec = "${pkgs.moonlight-qt}/bin/moonlight";
    icon = "moonlight";
    terminal = false;
    categories = [
      "Qt"
      "Game"
    ];
    extraConfig = {
      Keywords = "nvidia;gamestream;stream;sunshine;remote play;";
      StartupWMClass = "com.moonlight_stream.Moonlight";
    };
  };
in
{
  environment.systemPackages = [ pkgs.moonlight-qt ];

  # Moonlight replaces it's Qt launcher window with a separate SDL window when streaming starts.
  # The SDL window doesn't show up in the dock even though the Qt launcher window does.
  # This is a small wrapper to treat the stream window as the same as the Moonlight application so
  # that it shows up in the dock no matter the state the application is in.

  # Install it in XDG_DATA_HOME so it takes precedence over the system package's entry.
  home-manager.users.anthony.xdg.dataFile."applications/com.moonlight_stream.Moonlight.desktop".source =
    "${moonlightDesktop}/share/applications/com.moonlight_stream.Moonlight.desktop";
}
