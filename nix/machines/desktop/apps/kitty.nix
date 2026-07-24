{
  lib,
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
      package = pkgs.nixpkgsUnstable.kitty;

      shellIntegration.enableZshIntegration = true;

      font = {
        name = "MonaspiceNe Nerd Font Mono";
        size = 12;
      };

      settings = {
        allow_remote_control = true;
        clear_all_shortcuts = true;
        cursor_shape = "block";
        disable_ligatures = "always";
        enabled_layouts = "splits,stack";
        inactive_text_alpha = "1.0";
        remember_window_size = false;
        initial_window_width = "120c";
        initial_window_height = "40c";
        listen_on = "unix:@mykitty";
        tab_bar_edge = "left";
        tab_title_max_length = 18;
        tab_bar_margin_height = "0 1";
        text_composition_strategy = "1.0 10";
        touch_scroll_multiplier = "2.85";
        confirm_os_window_close = 0;
      };

      keybindings = {
        "ctrl+shift+c" = "copy_to_clipboard";
        "ctrl+insert" = "copy_to_clipboard";
        "ctrl+shift+v" = "paste_from_clipboard";
        "shift+insert" = "paste_from_clipboard";
        "ctrl+shift+backslash" = "launch --cwd=current --location=vsplit";
        "ctrl+shift+minus" = "launch --cwd=current --location=hsplit";
        "ctrl+shift+z" = "toggle_layout stack";
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

        # Let Atuin handle list navigation when its TUI is open.
        map --when-focus-on var:IS_ATUIN ctrl+j
        map --when-focus-on var:IS_ATUIN ctrl+k
      '';
    };

    # Atuin uses Ctrl+J/Ctrl+K for list navigation, but those keys are also Kitty
    # split navigation bindings. While Atuin's TUI is open, set a Kitty user var
    # so the conditional maps above pass those keys through to Atuin.
    programs.zsh.initContent = lib.mkOrder 1300 ''
      if (( $+functions[__atuin_search_cmd] )); then
        functions -c __atuin_search_cmd __atuin_search_cmd_without_kitty_var

        __atuin_search_cmd() {
          if [[ -n "$KITTY_WINDOW_ID" ]]; then
            printf '\033]1337;SetUserVar=IS_ATUIN=MQ==\007' > /dev/tty
          fi

          {
            __atuin_search_cmd_without_kitty_var "$@"
          } always {
            if [[ -n "$KITTY_WINDOW_ID" ]]; then
              printf '\033]1337;SetUserVar=IS_ATUIN\007' > /dev/tty
            fi
          }
        }
      fi
    '';
  };
}
