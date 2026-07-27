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
      "kitty/startup.session".text = ''
        # Show the zmx selector in the initial shell of a new kitty instance.
        launch --env ZMX_AUTO_ATTACH=1
      '';
      "kitty/dark-theme.auto.conf".text = ''
        include ${kittyThemes}/Alabaster_Dark.conf

        # Make the selected vertical tab the filled, high-contrast item.
        active_tab_foreground #cecece
        active_tab_background #323738
        inactive_tab_foreground #8a8a8a
        inactive_tab_background #0e1415
      '';
      "kitty/light-theme.auto.conf".text = ''
        include ${kittyThemes}/Alabaster.conf

        # Make the selected vertical tab the filled, high-contrast item.
        active_tab_foreground #000000
        active_tab_background #dedede
        inactive_tab_foreground #666666
        inactive_tab_background #f7f7f7
      '';
      "kitty/no-preference-theme.auto.conf".text = ''
        include ${kittyThemes}/Alabaster.conf

        active_tab_foreground #000000
        active_tab_background #dedede
        inactive_tab_foreground #666666
        inactive_tab_background #f7f7f7
      '';
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
        initial_window_width = "140c";
        initial_window_height = "40c";
        listen_on = "unix:@mykitty";
        startup_session = "startup.session";
        tab_bar_edge = "left";
        tab_bar_style = "separator";
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
        "ctrl+shift+backslash" = "launch --cwd=current --location=vsplit --env ZMX_AUTO_ATTACH=1";
        "ctrl+shift+minus" = "launch --cwd=current --location=hsplit --env ZMX_AUTO_ATTACH=1";
        "ctrl+shift+z" = "toggle_layout stack";
        # Only terminals opened with this shortcut should show the zmx selector.
        "ctrl+shift+t" = "launch --type=tab --cwd=current --env ZMX_AUTO_ATTACH=1";
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

        # Let fzf handle list navigation while a selector is open.
        map --when-focus-on var:IS_FZF ctrl+j
        map --when-focus-on var:IS_FZF ctrl+k
      '';
    };

    # Applications like Atuin and fzf use Ctrl+J/Ctrl+K for list navigation, but those keys are also
    # used for Kitty's split navigation.
    # Here we're setting up some zsh wrappers to set Kitty user vars to conditionally ignore the
    # split navigation while these apps are open.
    programs.zsh.initContent = lib.mkOrder 1300 ''
      # Atuin zsh wrapper to set Kitty user vars to allow Ctrl+J/Ctrl+K for list navigation
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

      # fzf zsh wrapper to set Kitty user vars to allow Ctrl+J/Ctrl+K for list navigation
      fzf() {
        if [[ -n "$KITTY_WINDOW_ID" ]]; then
          printf '\033]1337;SetUserVar=IS_FZF=MQ==\007' > /dev/tty
        fi

        {
          command fzf "$@"
        } always {
          if [[ -n "$KITTY_WINDOW_ID" ]]; then
            printf '\033]1337;SetUserVar=IS_FZF\007' > /dev/tty
          fi
        }
      }
    '';
  };
}
