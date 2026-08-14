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
    xdg.configFile = {
      "kitty/startup.session".text = ''
        # Show the zmx selector in the initial shell of a new kitty instance.
        launch --env ZMX_AUTO_ATTACH=1
      '';

      "kitty/tab_bar.py".text = ''
        import os

        import kitty.tab_bar as kitty_tab_bar
        from kitty.fast_data_types import Screen, get_boss, wcswidth
        from kitty.rgb import alpha_blend, color_from_int
        from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb
        from kitty.utils import color_as_int, sanitize_title

        INDENT = "  "
        ACTIVITY_MARKER = "● "
        ACCENT = as_rgb(0x168EEA)

        # Default is only 2 lines / row of text
        MAX_TAB_LINES = 4
        kitty_tab_bar.MAX_VERTICAL_TAB_LINES = MAX_TAB_LINES

        def fit(text: str, width: int, *, keep_right: bool = False) -> str:
            """Truncate text to a cell width, preserving the useful end of paths."""
            text = sanitize_title(text)
            if width <= 0:
                return ""
            if wcswidth(text) <= width:
                return text
            if width == 1:
                return "…"

            if keep_right:
                while text and wcswidth(text) > width - 1:
                    text = text[1:]
                return "…" + text

            while text and wcswidth(text) > width - 1:
                text = text[:-1]
            return text + "…"

        def take_cells(text: str, width: int) -> tuple[str, str]:
            used = 0
            for index, character in enumerate(text):
                character_width = max(0, wcswidth(character))
                if used + character_width > width:
                    return text[:index], text[index:]
                used += character_width
            return text, ""

        def wrap_cwd(text: str, width: int, max_lines: int) -> list[str]:
            """Wrap a path on directory boundaries when possible."""
            text = sanitize_title(text)
            lines = []
            while text and len(lines) < max_lines:
                if len(lines) == max_lines - 1:
                    lines.append(fit(text, width))
                    break

                line, remainder = take_cells(text, width)
                if remainder:
                    # Prefer wrapping after a slash, unless that would leave a
                    # very short line such as just the leading ~/.
                    slash = line.rfind("/")
                    if slash >= max(1, len(line) // 3):
                        split = slash + 1
                        remainder = line[split:] + remainder
                        line = line[:split]
                lines.append(line)
                text = remainder
            return lines

        def cwd_for_tab(tab_id: int) -> str:
            tab = get_boss().tab_for_id(tab_id)
            cwd = (tab.get_cwd_of_active_window() if tab else "") or ""
            home = os.path.expanduser("~")
            if cwd == home:
                return "~"
            if cwd.startswith(home + os.sep):
                return "~" + cwd[len(home):]
            return cwd

        def tab_line_height(draw_data: DrawData, screen: Screen) -> int:
            tab_manager = get_boss().os_window_map.get(draw_data.os_window_id)
            tab_count = len(tab_manager.tab_bar.last_laid_out_tabs) if tab_manager else 0
            return max(1, min(MAX_TAB_LINES, screen.lines // max(1, tab_count)))

        def clear_row(screen: Screen) -> None:
            screen.cursor.x = 0
            screen.draw(" " * screen.columns)
            screen.cursor.x = 0

        def draw_tab(
            draw_data: DrawData,
            screen: Screen,
            tab: TabBarData,
            before: int,
            max_tab_length: int,
            index: int,
            is_last: bool,
            extra_data: ExtraData,
        ) -> int:
            del before, index, is_last, extra_data

            original_fg = screen.cursor.fg
            original_bg = screen.cursor.bg
            content_width = min(max_tab_length, screen.columns)
            show_activity = tab.needs_attention or tab.has_activity_since_last_focus

            clear_row(screen)
            screen.cursor.bold = True
            screen.draw(INDENT)
            if show_activity:
                screen.cursor.fg = ACCENT
                screen.draw(ACTIVITY_MARKER)
                screen.cursor.fg = original_fg
            title_width = content_width - wcswidth(INDENT) - (
                wcswidth(ACTIVITY_MARKER) if show_activity else 0
            )
            screen.draw(fit(tab.title, title_width))

            line_height = tab_line_height(draw_data, screen)
            cwd_width = content_width - wcswidth(INDENT)
            cwd_lines = wrap_cwd(cwd_for_tab(tab.tab_id), cwd_width, line_height - 1)
            for line_number in range(1, line_height):
                screen.cursor.y += 1
                screen.cursor.bg = original_bg
                screen.cursor.bold = False
                clear_row(screen)

                if line_number <= len(cwd_lines):
                    foreground = color_from_int(original_fg >> 8)
                    background = color_from_int(original_bg >> 8)
                    muted = alpha_blend(foreground, background, 0.68)
                    screen.cursor.fg = as_rgb(color_as_int(muted))
                    screen.draw(INDENT + cwd_lines[line_number - 1])

            screen.cursor.bold = False
            # Kitty clears the unused sidebar rows before setting up the next
            # tab. Do not leave the active tab's blue background on the
            # cursor, or that clear will paint the rest of the sidebar blue.
            screen.cursor.fg = 0
            screen.cursor.bg = 0
            return screen.cursor.x
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

        active_tab_foreground #ffffff
        active_tab_background #168eea
        inactive_tab_foreground #454545
        inactive_tab_background #eeeeea
        tab_bar_background #eeeeea
        tab_bar_margin_color #eeeeea
      '';

      "kitty/no-preference-theme.auto.conf".text = ''
        include ${kittyThemes}/Alabaster.conf

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
    };

    programs.kitty = {
      enable = true;
      package = pkgs.nixosUnstable.kitty;

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
        tab_bar_style = "custom";
        tab_bar_min_tabs = 1;
        tab_title_max_length = 24;
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
