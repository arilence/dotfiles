{
  config,
  lib,
  pkgs,
  ...
}:

let
  zmx-session = import ./zmx { inherit pkgs; };
  kittyThemes = "${pkgs.kitty-themes}/share/kitty-themes/themes";
  alabasterLightOverrides = ''
    # Override the Alabaster light theme's default colours for better contrast.
    color7 #454545
    color15 #303030
    color8 #666666
  '';
  primaryModifier = lib.strings.toLower config.arilence.workstation.keybindings.primaryModifier;
in
{
  home-manager.users.anthony = {
    xdg.configFile = {
      "kitty/open-actions.conf".text = ''
        protocol file
        fragment_matches ^[0-9]+$
        action launch --type=overlay nvim +''${FRAGMENT} -- ''${FILE_PATH}
      '';

      "kitty/ssh.conf".text = ''
        # Keeps Ctrl+C working while connecting to unreachable hosts.
        askpass ssh

        # exe.dev's shell does not support Kitty's SSH bootstrap commands.
        hostname exe.dev
        delegate ssh
      '';

      "kitty/startup.session".text = ''
        # Show the zmx selector in the initial shell of a new kitty instance.
        launch --env ZMX_AUTO_ATTACH=1
      '';

      "kitty/tab_bar.py".source = pkgs.replaceVars ./kitty/sidebar.py {
        zmx_session = zmx-session;
      };

      "kitty/sidebar_watcher.py".text = ''
        import sys

        sys.path.insert(0, "${zmx-session}/lib")
        from zmx_kitty import install, on_cmd_startstop, on_set_user_var, on_title_change

        install()
      '';

      # kitty.themeFile exists but doesn't allow for setting a dark and light theme separately.
      "kitty/dark-theme.auto.conf".text = ''
        include ${kittyThemes}/Alabaster_Dark.conf

        # A dark sidebar with a bright, cmux-like selected tab.
        active_tab_foreground #ffffff
        active_tab_background #168eea
        inactive_tab_foreground #c3c4c1
        inactive_tab_background #20221e
        tab_bar_background #20221e
        tab_bar_margin_color #20221e
      '';

      "kitty/light-theme.auto.conf".text = ''
        include ${kittyThemes}/Alabaster.conf
        ${alabasterLightOverrides}

        active_tab_foreground #ffffff
        active_tab_background #168eea
        inactive_tab_foreground #454545
        inactive_tab_background #eeeeea
        tab_bar_background #eeeeea
        tab_bar_margin_color #eeeeea
      '';

      "kitty/no-preference-theme.auto.conf".text = ''
        include ${kittyThemes}/Alabaster.conf
        ${alabasterLightOverrides}

        active_tab_foreground #ffffff
        active_tab_background #168eea
        inactive_tab_foreground #454545
        inactive_tab_background #eeeeea
        tab_bar_background #eeeeea
        tab_bar_margin_color #eeeeea
      '';

      "kitty/neighboring_window.py".source =
        "${pkgs.vimPlugins.smart-splits-nvim}/kitty/neighboring_window.py";
      "kitty/relative_resize.py".source = "${pkgs.vimPlugins.smart-splits-nvim}/kitty/relative_resize.py";
      "kitty/split_window.py".source = "${pkgs.vimPlugins.smart-splits-nvim}/kitty/split_window.py";
      "kitty/toggle_tab_bar.py".text = ''
        from kitty.boss import Boss
        from kitty.constants import is_wayland
        from kitty.fast_data_types import apply_options_update, get_options, set_options
        from kittens.tui.handler import result_handler


        def main(args: list[str]) -> None:
            pass


        @result_handler(no_ui=True)
        def handle_result(
            args: list[str],
            answer: str,
            target_window_id: int,
            boss: Boss,
        ) -> None:
            opts = get_options()
            is_hidden = opts.tab_bar_style == "hidden"
            opts.tab_bar_style = "custom" if is_hidden else "hidden"

            set_options(
                opts,
                is_wayland(),
                boss.args.debug_rendering,
                boss.args.debug_font_fallback,
            )
            apply_options_update()
            for tab_manager in boss.all_tab_managers:
                tab_manager.apply_options()
                if not is_hidden:
                    # With a hidden tab bar, TabBar.layout() returns before it
                    # replaces these rectangles. Clear the cached visible-bar
                    # geometry so its top/bottom fill strips are not painted.
                    tab_manager.tab_bar.blank_rects = ()
                    tab_manager.tab_bar._last_viewport = None
                    tab_manager.tab_bar.laid_out_once = False
                tab_manager.resize()
      '';
    };

    programs.kitty = {
      enable = true;
      package = pkgs.nixosUnstable.kitty;

      shellIntegration.enableZshIntegration = true;
      shellIntegration.mode = "no-cursor";

      font = {
        name = "MonaspiceNe Nerd Font Mono";
        size = 12;
      };

      settings = {
        allow_remote_control = true;
        clear_all_shortcuts = true;
        cursor_shape = "block";
        disable_ligatures = "always";
        # Keep CLI hints readable when applications use ANSI faint text.
        dim_opacity = "0.75";
        # Kitty's vertical split axis arranges panes above and below each other.
        enabled_layouts = "splits:split_axis=vertical,stack";
        inactive_text_alpha = "1.0";
        remember_window_size = false;
        initial_window_width = "140c";
        initial_window_height = "40c";
        listen_on = "unix:@mykitty";
        startup_session = "startup.session";
        tab_bar_edge = "left";
        tab_bar_style = "custom";
        tab_bar_min_tabs = 1;
        watcher = "sidebar_watcher.py";
        tab_title_max_length = 20;
        tab_bar_margin_height = "4 4";
        text_composition_strategy = "1.0 10";
        touch_scroll_multiplier = "2.85";
        confirm_os_window_close = 0;
      };

      keybindings = {
        "ctrl+shift+c" = "copy_to_clipboard";
        "ctrl+insert" = "copy_to_clipboard";
        "ctrl+shift+v" = "paste_from_clipboard";
        "shift+insert" = "paste_from_clipboard";
        "ctrl+shift+backslash" = "launch --cwd=last_reported --location=vsplit --env ZMX_AUTO_ATTACH=1";
        "ctrl+shift+minus" = "launch --cwd=last_reported --location=hsplit --env ZMX_AUTO_ATTACH=1";
        "ctrl+shift+z" = "toggle_layout stack";
        "ctrl+[" = "kitten toggle_tab_bar.py";
        # Only terminals opened with this shortcut should show the zmx selector.
        "ctrl+shift+t" = "launch --type=tab --cwd=last_reported --env ZMX_AUTO_ATTACH=1";
        "${primaryModifier}+1" = "goto_tab 1";
        "${primaryModifier}+2" = "goto_tab 2";
        "${primaryModifier}+3" = "goto_tab 3";
        "${primaryModifier}+4" = "goto_tab 4";
        "${primaryModifier}+5" = "goto_tab 5";
        "${primaryModifier}+6" = "goto_tab 6";
        "${primaryModifier}+7" = "goto_tab 7";
        "${primaryModifier}+8" = "goto_tab 8";
        "${primaryModifier}+9" = "goto_tab 9";
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
