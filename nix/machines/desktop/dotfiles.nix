{ ... }:

{
  xdg.configFile = {
    "mise/config.toml" = {
      source = ../../../config/mise/config.toml;
      force = true;
    };

    "lazygit/config.yml" = {
      source = ../../../config/lazygit/config.yml;
      force = true;
    };

    "zellij/config.kdl" = {
      source = ../../../config/zellij/config.kdl;
      force = true;
    };

    "vs-code/User/keybindings.json" = {
      source = ../../../config/vs-code/keybindings.json;
      force = true;
    };
    "vs-code/User/settings.json" = {
      source = ../../../config/vs-code/settings.json;
      force = true;
    };

    "Cursor/User/keybindings.json" = {
      source = ../../../config/Cursor/keybindings.json;
      force = true;
    };
    "Cursor/User/settings.json" = {
      source = ../../../config/Cursor/settings.json;
      force = true;
    };
  };

  home.file = {
    ".editorconfig" = {
      source = ../../../config/editorconfig;
      force = true;
    };
  };
}
