"""Vertical tab groups with live pane selection and native drag and drop."""

import os
import sys
from dataclasses import dataclass

sys.path.insert(0, "@zmx_session@/lib")
from zmx_kitty import title_for_window

from kitty.fast_data_types import (
    GLFW_MOUSE_BUTTON_LEFT,
    GLFW_PRESS,
    GLFW_RELEASE,
    get_boss,
    get_window_being_dragged,
    set_tab_being_dragged,
    set_window_being_dragged,
    wcswidth,
)
from kitty.rgb import alpha_blend, color_from_int
from kitty.tab_bar import CellRange, TabBar, TabExtent, WindowDropTarget, as_rgb
from kitty.tabs import TabManager
from kitty.utils import color_as_int, path_from_osc7_url, sanitize_title

INDENT = "  "
JUMP_MODIFIER = "@primary_modifier@"
ACTIVITY_MARKER = "● "
ACCENT = as_rgb(0x168EEA)
MAX_ENTRY_LINES = 4


def blend(foreground, background, opacity):
    return as_rgb(
        color_as_int(
            alpha_blend(
                color_from_int(foreground >> 8),
                color_from_int(background >> 8),
                opacity,
            )
        )
    )


def group_title(index):
    return f"{JUMP_MODIFIER}+{index}" if index <= 9 else f"Group {index}"


def draw_heading(screen, text, width):
    text = fit(text, width)
    # The tab-bar screen has no child writer, so its parser can safely handle OSC 66.
    for start in range(0, len(text), 5):
        chunk = text[start : start + 5]
        cells = (len(chunk) * 4 + 4) // 5
        screen.restore_scrollback(
            f"\x1b]66;n=4:d=5:w={cells}:v=2;{chunk}\a".encode()
        )


def fit(text, width):
    text = sanitize_title(text)
    if width <= 0:
        return ""
    if wcswidth(text) <= width:
        return text
    while text and wcswidth(text) > width - 1:
        text = text[:-1]
    return text + "…"


def take_cells(text, width):
    used = 0
    for index, character in enumerate(text):
        character_width = max(0, wcswidth(character))
        if used + character_width > width:
            return text[:index], text[index:]
        used += character_width
    return text, ""


def wrap_cwd(text, width, max_lines):
    text = sanitize_title(text)
    lines = []
    while text and width > 0 and len(lines) < max_lines:
        if len(lines) == max_lines - 1:
            lines.append(fit(text, width))
            break
        line, remainder = take_cells(text, width)
        if remainder:
            slash = line.rfind("/")
            if slash >= max(1, len(line) // 3):
                split = slash + 1
                remainder = line[split:] + remainder
                line = line[:split]
        lines.append(line)
        text = remainder
    return lines


def cwd_for_window(window):
    if not window:
        return ""
    # OSC 7 comes from the shell inside zmx; the attachment process can be stale.
    cwd = (
        (
            path_from_osc7_url(window.screen.last_reported_cwd)
            if window.screen.last_reported_cwd
            else ""
        )
        or window.cwd_of_child
        or ""
    )
    home = os.path.expanduser("~")
    if cwd == home:
        return "~"
    if cwd.startswith(home + os.sep):
        return "~" + cwd[len(home) :]
    return cwd


@dataclass
class Entry:
    tab: object
    window_id: int
    title: str
    cwd: str
    active: bool
    attention: bool = False

    @property
    def indent(self):
        return INDENT if self.window_id else ""


def entries_for_tabs(data):
    boss = get_boss()
    entries = []
    for index, item in enumerate(data, 1):
        tab = boss.tab_for_id(item.tab_id)
        # Overlays belong to their underlying pane, not to a new child entry.
        windows = (
            [
                boss.window_id_map[group.main_window_id]
                for group in tab.windows.iter_all_layoutable_groups()
            ]
            if tab
            else []
        )
        entries.append(
            Entry(
                item,
                0,
                group_title(index),
                "",
                False,
            )
        )
        for window in windows:
            entries.append(
                Entry(
                    item,
                    window.id,
                    title_for_window(window),
                    cwd_for_window(window),
                    item.is_active
                    and window.id == tab.windows.active_group.main_window_id,
                    window.needs_attention or window.has_activity_since_last_focus,
                )
            )
    return entries


def update_vertical(self, data):
    screen = self.screen
    self.last_laid_out_tabs = data
    self.tab_extents = ()
    self.pane_extents = ()
    screen.cursor.x = screen.cursor.y = 0
    screen.erase_in_display(2, False)
    entries = entries_for_tabs(data)
    # Keep titles ahead of optional directory rows. Overflow stays explicit,
    # as in the original sidebar, without introducing a scrolling interaction.
    overflow = len(entries) > screen.lines and screen.lines > 1
    visible = entries[: max(1, screen.lines - int(overflow))]
    heights = [1] * len(visible)
    remaining = screen.lines - len(visible) - int(overflow)
    paths = [
        wrap_cwd(e.cwd, screen.columns - 1 - wcswidth(e.indent), MAX_ENTRY_LINES - 1)
        for e in visible
    ]
    for level in range(1, MAX_ENTRY_LINES):
        for i, path in enumerate(paths):
            if remaining > 0 and len(path) >= level:
                heights[i] += 1
                remaining -= 1
    total = sum(heights) + int(overflow)
    row = (
        max(0, (screen.lines - total) // 2)
        if self.tab_bar_align == "center"
        else (max(0, screen.lines - total) if self.tab_bar_align == "end" else 0)
    )
    extents, panes = [], []
    for entry, height in zip(visible, heights):
        tab = entry.tab._replace(is_active=False)
        normal_fg = as_rgb(self.draw_data.tab_fg(tab))
        normal_bg = as_rgb(self.draw_data.tab_bg(tab))
        background = blend(ACCENT, normal_bg, 0.18) if entry.active else normal_bg
        foreground = normal_fg
        if entry.active:
            foreground = blend(ACCENT, normal_fg, 0.5)
        elif not entry.window_id:
            foreground = blend(normal_fg, normal_bg, 0.78)
        for offset in range(height):
            screen.cursor.x, screen.cursor.y = 0, row + offset
            screen.cursor.fg, screen.cursor.bg = foreground, background
            screen.cursor.bold, screen.cursor.italic = False, False
            screen.draw(" " * screen.columns)
            if entry.window_id:
                screen.cursor.x = 0
                screen.cursor.fg = (
                    ACCENT if entry.active else blend(normal_fg, normal_bg, 0.3)
                )
                screen.draw("│")
                screen.cursor.fg = foreground
            screen.cursor.x = wcswidth(entry.indent)
            width = screen.columns - 1 - wcswidth(entry.indent)
            if offset == 0:
                screen.cursor.bold = entry.active
                if entry.attention:
                    screen.cursor.fg = ACCENT
                    screen.draw(ACTIVITY_MARKER)
                    screen.cursor.fg = foreground
                    width -= wcswidth(ACTIVITY_MARKER)
                if entry.window_id:
                    screen.draw(fit(entry.title, width))
                else:
                    draw_heading(screen, entry.title, width)
            else:
                screen.cursor.fg = blend(foreground, background, 0.68)
                screen.draw(wrap_cwd(entry.cwd, width, height - 1)[offset - 1])
        extent = TabExtent(
            entry.tab.tab_id,
            CellRange(0, screen.columns - 1),
            CellRange(row, row + height - 1),
        )
        if entry.window_id:
            panes.append((extent, entry.window_id))
            extents[-1] = extents[-1]._replace(
                y=CellRange(extents[-1].y.start, extent.y.end)
            )
        else:
            extents.append(extent)
        row += height
    if overflow:
        screen.cursor.x, screen.cursor.y = 0, min(row, screen.lines - 1)
        screen.cursor.fg, screen.cursor.bg = ACCENT, 0
        screen.draw("…")
    screen.cursor.fg = screen.cursor.bg = 0
    screen.cursor.bold = False
    self.tab_extents, self.pane_extents = tuple(extents), tuple(panes)
    self.draw_drop_insert_marker()
    return self._update_edge_defaults(True)


def pane_at(bar, x, y):
    if not bar.tab_id_at(int(x), int(y)):
        return 0
    g = bar.window_geometry
    col, row = int(x - g.left) // bar.cell_width, int(y - g.top) // bar.cell_height
    return next(
        (
            wid
            for extent, wid in getattr(bar, "pane_extents", ())
            if extent.contains(col, row)
        ),
        0,
    )


def window_drop_target_at(self, x, y):
    if not self.laid_out_once:
        return WindowDropTarget(before_tab_id=0)
    coordinate, spans = self._drop_spans(x, y)
    # A group's height grows with its panes. Keep insertion zones small so
    # its header remains a join target even for tall groups.
    for i, (tab_id, start, end) in enumerate(spans):
        edge = min(self.cell_height / 4, (end - start) * 0.1)
        if coordinate < start + edge:
            return WindowDropTarget(before_tab_id=tab_id)
        if coordinate < end - edge:
            return WindowDropTarget(tab_id=tab_id)
        if coordinate < end:
            return WindowDropTarget(
                before_tab_id=spans[i + 1][0] if i + 1 < len(spans) else 0
            )
    return WindowDropTarget(before_tab_id=0)


# Config reloads execute this file again in a fresh namespace.
original_mouse = getattr(
    TabManager.handle_tab_bar_mouse, "sidebar_original", TabManager.handle_tab_bar_mouse
)
original_drop = getattr(
    TabManager.on_window_drop, "sidebar_original", TabManager.on_window_drop
)
original_tab_drop_move = getattr(
    TabManager.on_tab_drop_move, "sidebar_original", TabManager.on_tab_drop_move
)
original_tab_drop = getattr(
    TabManager.on_tab_drop, "sidebar_original", TabManager.on_tab_drop
)


def handle_tab_bar_mouse(self, x, y, button, modifiers, action):
    pending = getattr(self, "sidebar_pressed_pane", 0)
    if pending:
        if button == -1:
            self.handle_window_title_bar_mouse(pending, x, y, button, modifiers, action)
            if get_window_being_dragged()[1]:
                self.sidebar_pressed_pane = 0
                set_tab_being_dragged()
        elif button == GLFW_MOUSE_BUTTON_LEFT and action == GLFW_RELEASE:
            self.sidebar_pressed_pane = 0
            set_tab_being_dragged()
            set_window_being_dragged()
        return
    if button == GLFW_MOUSE_BUTTON_LEFT and action == GLFW_PRESS:
        if window_id := pane_at(self.tab_bar, x, y):
            self.recent_tab_bar_mouse_events.clear()
            self.recent_title_bar_mouse_events.clear()
            self.handle_window_title_bar_mouse(
                window_id, x, y, button, modifiers, action
            )
            self.sidebar_pressed_pane = window_id
            # Kitty forwards sidebar motion only with a pending tab drag. Arm
            # that route until the native window drag takes over at threshold.
            tab = get_boss().window_id_map[window_id].tabref()
            set_tab_being_dragged(tab.id, False, x, y)
            return
    return original_mouse(self, x, y, button, modifiers, action)


def on_window_drop(self, x, y, window_id):
    from kitty.fast_data_types import viewport_for_window

    region = viewport_for_window(self.os_window_id)[1]
    window = get_boss().window_id_map.get(window_id)
    if window and region.left <= x < region.right and region.top <= y < region.bottom:
        target = self.tab_bar.window_drop_target_at(x, y)
        if target.before_tab_id is None and target.tab_id == window.tab_id:
            self._clear_force_show_title_bars()
            return
    return original_drop(self, x, y, window_id)


def on_tab_drop_move(self, tab_id=0, is_dest=False, x=0, y=0):
    from kitty.fast_data_types import viewport_for_window

    self.sidebar_merge_target = 0
    self._set_drag_target_tab(0)
    original_tab_drop_move(self, tab_id, is_dest, x, y)
    if not is_dest or self.tab_being_dropped is None:
        return
    region = viewport_for_window(self.os_window_id)[1]
    if not (region.left <= x < region.right and region.top <= y < region.bottom):
        return
    target = self.tab_bar.window_drop_target_at(x, y)
    if target.before_tab_id is None and self.tab_for_id(target.tab_id) is not None:
        # Retain the native pending drop so Wayland can finish the merge even
        # when its source-finished callback arrives before the drop data.
        self.sidebar_merge_target = target.tab_id
        self.tab_bar.tab_drop_insert_before = None
        self._cancel_drag_hover()
        self._set_drag_target_tab(target.tab_id if target.tab_id != tab_id else 0)
        self.mark_tab_bar_dirty()


def on_tab_drop(self, x, y, bypass_move=False):
    pending = self.tab_being_dropped
    if pending is None:
        return
    if not bypass_move:
        self.on_tab_drop_move(pending.tab_id, True, x, y)
    target_id = getattr(self, "sidebar_merge_target", 0)
    if not target_id:
        return original_tab_drop(self, x, y, bypass_move=True)

    boss = get_boss()
    source = boss.tab_for_id(pending.tab_id)
    destination = self.tab_for_id(target_id)
    self.on_tab_drop_move()
    set_tab_being_dragged()
    if source is None or destination is None or source is destination:
        return
    active_window = source.active_window
    windows = [
        boss.window_id_map[group.main_window_id]
        for group in source.windows.iter_all_layoutable_groups()
    ]
    self.finish_tab_drag_hover(restore_focus=False)
    with boss.suppress_focus_change_events():
        for window in windows:
            boss._move_window_to(window, target_tab_id=destination.id)
        if active_window is not None:
            boss.set_active_window(active_window, switch_os_window_if_needed=True)


TabBar.update_vertical = update_vertical
TabBar.window_drop_target_at = window_drop_target_at
handle_tab_bar_mouse.sidebar_original = original_mouse
on_window_drop.sidebar_original = original_drop
on_tab_drop_move.sidebar_original = original_tab_drop_move
on_tab_drop.sidebar_original = original_tab_drop
TabManager.handle_tab_bar_mouse = handle_tab_bar_mouse
TabManager.on_window_drop = on_window_drop
TabManager.on_tab_drop_move = on_tab_drop_move
TabManager.on_tab_drop = on_tab_drop


def draw_tab(
    draw_data, screen, tab, before, max_tab_length, index, is_last, extra_data
):
    # Kitty requires this entry point even though update_vertical draws groups.
    draw_heading(screen, group_title(index), max_tab_length)
    return screen.cursor.x
