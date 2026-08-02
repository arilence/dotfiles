{ lib, pkgs, ... }:

let
  textEditor = "org.gnome.TextEditor.desktop";
  textMimeTypes = [
    "application/json"
    "application/toml"
    "application/x-shellscript"
    "application/x-yaml"
    "application/yaml"
    "text/csv"
    "text/english"
    "text/markdown"
    "text/plain"
    "text/x-c"
    "text/x-c++"
    "text/x-c++hdr"
    "text/x-c++src"
    "text/x-chdr"
    "text/x-csrc"
    "text/x-java"
    "text/x-makefile"
    "text/x-markdown"
    "text/x-moc"
    "text/x-pascal"
    "text/x-tcl"
    "text/x-tex"
    "text/yaml"
  ];
in
{
  environment.systemPackages = [ pkgs.gnome-text-editor ];

  # Keep GNOME Text Editor as the default after Zen registers its MIME handlers.
  home-manager.users.anthony.xdg.mimeApps.defaultApplications = lib.genAttrs textMimeTypes (
    _: textEditor
  );
}
