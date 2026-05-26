{
  pkgs,
  ...
}:

let
  kittyThemes = "${pkgs.kitty-themes}/share/kitty-themes/themes";
in
{
  home-manager.users.anthony = {
    # kitty.themeFile exists but doesn't allow for setting a dark and light theme separately.
    xdg.configFile = {
      "kitty/dark-theme.auto.conf".source = "${kittyThemes}/Alabaster_Dark.conf";
      "kitty/light-theme.auto.conf".source = "${kittyThemes}/Alabaster.conf";
      "kitty/no-preference-theme.auto.conf".source = "${kittyThemes}/Alabaster.conf";
      "kitty/neighboring_window.py".source =
        "${pkgs.vimPlugins.smart-splits-nvim}/kitty/neighboring_window.py";
      "kitty/relative_resize.py".source = "${pkgs.vimPlugins.smart-splits-nvim}/kitty/relative_resize.py";
      "kitty/split_window.py".source = "${pkgs.vimPlugins.smart-splits-nvim}/kitty/split_window.py";
    };

    programs.kitty = {
      enable = true;

      shellIntegration.enableZshIntegration = true;

      font = {
        name = "MonaspiceNe Nerd Font Mono";
      };

      settings = {
        allow_remote_control = true;
        clear_all_shortcuts = true;
        cursor_shape = "block";
        disable_ligatures = "always";
        enabled_layouts = "splits";
        inactive_text_alpha = "1.0";
        remember_window_size = false;
        initial_window_width = "120c";
        initial_window_height = "40c";
        listen_on = "unix:@mykitty";
      };

      keybindings = {
        "ctrl+shift+c" = "copy_to_clipboard";
        "ctrl+insert" = "copy_to_clipboard";
        "ctrl+shift+v" = "paste_from_clipboard";
        "shift+insert" = "paste_from_clipboard";
        "ctrl+shift+backslash" = "launch --cwd=current --location=vsplit";
        "ctrl+shift+minus" = "launch --cwd=current --location=hsplit";
        "ctrl+shift+t" = "new_tab_with_cwd";
        "alt+1" = "goto_tab 1";
        "alt+2" = "goto_tab 2";
        "alt+3" = "goto_tab 3";
        "alt+4" = "goto_tab 4";
        "alt+5" = "goto_tab 5";
        "alt+6" = "goto_tab 6";
        "ctrl+h" = "neighboring_window left";
        "ctrl+j" = "neighboring_window down";
        "ctrl+k" = "neighboring_window up";
        "ctrl+l" = "neighboring_window right";
        "alt+h" = "kitten relative_resize.py left 3";
        "alt+j" = "kitten relative_resize.py down 3";
        "alt+k" = "kitten relative_resize.py up 3";
        "alt+l" = "kitten relative_resize.py right 3";
      };

      extraConfig = ''
        # Conditionally enable/disable shortcuts using smart-splits.nvim
        map --when-focus-on var:IS_NVIM ctrl+h
        map --when-focus-on var:IS_NVIM ctrl+j
        map --when-focus-on var:IS_NVIM ctrl+k
        map --when-focus-on var:IS_NVIM ctrl+l
        map --when-focus-on var:IS_NVIM alt+h
        map --when-focus-on var:IS_NVIM alt+j
        map --when-focus-on var:IS_NVIM alt+k
        map --when-focus-on var:IS_NVIM alt+l
      '';
    };
  };
}
