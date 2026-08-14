{
  config,
  lib,
  pkgs,
  ...
}:

let
  kittyThemes = "${pkgs.kitty-themes}/share/kitty-themes/themes";
  primaryModifier = lib.strings.toLower config.arilence.workstation.keybindings.primaryModifier;
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
        from kitty.tab_bar import (
            CellRange,
            DrawData,
            ExtraData,
            TabBarData,
            TabExtent,
            as_rgb,
        )
        from kitty.utils import color_as_int, path_from_osc7_url, sanitize_title

        INDENT = "  "
        ACTIVITY_MARKER = "● "
        ACCENT = as_rgb(0x168EEA)

        # Let long CWDs use extra rows without reserving them for every tab.
        MAX_TAB_LINES = 4
        kitty_tab_bar.MAX_VERTICAL_TAB_LINES = MAX_TAB_LINES
        TAB_LINE_HEIGHTS: dict[int, int] = {}

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

        def kitty_tab(tab_id: int):
            return get_boss().tab_for_id(tab_id)

        def zmx_session_for_tab(tab_id: int) -> str:
            """Return the session from the active `zmx attach SESSION` process."""
            tab = kitty_tab(tab_id)
            window = tab.active_window if tab else None
            if not window:
                return ""

            for process in window.child.foreground_processes:
                command = process.get("cmdline") or ()
                if len(command) < 3 or os.path.basename(command[0]) != "zmx":
                    continue
                if command[1] in ("attach", "a"):
                    return command[2]
            return ""

        def title_for_tab(tab: TabBarData) -> str:
            kitty_tab_data = kitty_tab(tab.tab_id)
            # Preserve explicit Kitty tab titles (including kzmx's optional
            # display title). Otherwise use the zmx session name instead of
            # the inner shell's CWD-based window title.
            if kitty_tab_data and kitty_tab_data.name:
                return kitty_tab_data.name
            return zmx_session_for_tab(tab.tab_id) or tab.title

        def cwd_for_tab(tab_id: int) -> str:
            tab = get_boss().tab_for_id(tab_id)
            window = tab.active_window if tab else None
            reported_cwd = (
                path_from_osc7_url(window.screen.last_reported_cwd)
                if window and window.screen.last_reported_cwd
                else ""
            )
            # A zmx client remains in the directory from which it attached, so
            # /proc reports that stale directory. Kitty shell integration's
            # OSC 7 value comes from the shell inside zmx and stays current.
            cwd = reported_cwd or ((tab.get_cwd_of_active_window() if tab else "") or "")
            home = os.path.expanduser("~")
            if cwd == home:
                return "~"
            if cwd.startswith(home + os.sep):
                return "~" + cwd[len(home):]
            return cwd

        def desired_tab_height(tab: TabBarData, max_tab_length: int) -> int:
            cwd_width = max(0, max_tab_length - wcswidth(INDENT))
            cwd_lines = wrap_cwd(cwd_for_tab(tab.tab_id), cwd_width, MAX_TAB_LINES - 1)
            return 1 + len(cwd_lines)

        def allocate_tab_heights(
            data: list[TabBarData] | tuple[TabBarData, ...],
            available_lines: int,
            max_tab_length: int,
        ) -> tuple[list[int], bool]:
            """Allocate only the rows each tab needs, within the sidebar height."""
            if not data or available_lines <= 0:
                return [], False

            if len(data) > available_lines:
                if available_lines == 1:
                    return [1], False
                return [1] * (available_lines - 1), True

            desired = [desired_tab_height(tab, max_tab_length) for tab in data]
            heights = [1] * len(data)
            remaining = available_lines - len(data)

            # Give every tab its second line before assigning third or fourth
            # lines. This preserves as much CWD information as possible when
            # the sidebar is too short for every wrapped path.
            for line_height in range(2, MAX_TAB_LINES + 1):
                for index, desired_height in enumerate(desired):
                    if remaining == 0:
                        return heights, False
                    if desired_height >= line_height:
                        heights[index] += 1
                        remaining -= 1
            return heights, False

        def update_vertical(self, data) -> bool:
            """Kitty's vertical layout, with a separate height for each tab."""
            screen = self.screen
            self.last_laid_out_tabs = data
            self.tab_extents = ()
            screen.cursor.x = screen.cursor.y = 0
            screen.erase_in_display(2, False)
            if not data:
                return self._update_edge_defaults(True)

            max_tab_length = max(1, screen.columns - 1)
            heights, draw_ellipsis = allocate_tab_heights(
                data, screen.lines, max_tab_length
            )
            rows_to_draw = len(heights)
            total_lines = sum(heights) + int(draw_ellipsis)
            if self.tab_bar_align == "center":
                start_row = max(0, (screen.lines - total_lines) // 2)
            elif self.tab_bar_align == "end":
                start_row = max(0, screen.lines - total_lines)
            else:
                start_row = 0

            TAB_LINE_HEIGHTS.clear()
            TAB_LINE_HEIGHTS.update(
                (tab.tab_id, height)
                for tab, height in zip(data[:rows_to_draw], heights)
            )

            extents = []
            row = start_row
            for index, (tab, height) in enumerate(
                zip(data[:rows_to_draw], heights)
            ):
                screen.cursor.x = 0
                screen.cursor.y = row
                screen.cursor.bg = as_rgb(self.draw_data.tab_bg(tab))
                screen.cursor.fg = as_rgb(self.draw_data.tab_fg(tab))
                screen.cursor.bold, screen.cursor.italic = (
                    self.active_font_style
                    if tab.is_active
                    else self.inactive_font_style
                )
                self.draw_func(
                    self.draw_data,
                    screen,
                    tab,
                    0,
                    max_tab_length,
                    index + 1,
                    True,
                    ExtraData(),
                )
                extents.append(
                    TabExtent(
                        tab_id=tab.tab_id,
                        x=CellRange(0, screen.columns - 1),
                        y=CellRange(row, min(screen.lines - 1, row + height - 1)),
                    )
                )
                row += height

            if draw_ellipsis:
                screen.cursor.x = 0
                screen.cursor.y = row
                screen.cursor.bg = as_rgb(color_as_int(self.draw_data.default_bg))
                screen.cursor.fg = as_rgb(0xFF0000)
                screen.draw("…")
            self.tab_extents = tuple(extents)
            return self._update_edge_defaults(True)

        # Kitty's built-in vertical layout uses one fixed height for every tab.
        # Install the variable-height version before Kitty loads draw_tab below.
        kitty_tab_bar.TabBar.update_vertical = update_vertical

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
            screen.draw(fit(title_for_tab(tab), title_width))

            line_height = TAB_LINE_HEIGHTS.get(tab.tab_id, 1)
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
        "ctrl+shift+backslash" = "launch --cwd=current --location=vsplit --env ZMX_AUTO_ATTACH=1";
        "ctrl+shift+minus" = "launch --cwd=current --location=hsplit --env ZMX_AUTO_ATTACH=1";
        "ctrl+shift+z" = "toggle_layout stack";
        # Only terminals opened with this shortcut should show the zmx selector.
        "ctrl+shift+t" = "launch --type=tab --cwd=current --env ZMX_AUTO_ATTACH=1";
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
