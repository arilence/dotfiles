{ ... }:

{
  xdg.configFile = {
    "lazygit/config.yml" = {
      source = ../../../config/lazygit/config.yml;
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
