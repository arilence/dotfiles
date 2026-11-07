"""Vertical tab groups with live pane selection and native drag and drop."""

import os
import sys
from dataclasses import dataclass

sys.path.insert(0, "@zmx_session@/lib")
from zmx_kitty import title_for_tab, title_for_window

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
ACTIVITY_MARKER = "● "
ACCENT = as_rgb(0x168EEA)
MAX_ENTRY_LINES = 4


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
        return INDENT * (2 if self.window_id else 1)


def entries_for_tabs(data):
    boss = get_boss()
    entries = []
    for item in data:
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
                title_for_tab(item),
                cwd_for_window(tab.active_window) if tab and len(windows) <= 1 else "",
                item.is_active,
                item.needs_attention or item.has_activity_since_last_focus,
            )
        )
        if len(windows) > 1:
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
        tab = entry.tab._replace(is_active=entry.active)
        foreground = as_rgb(self.draw_data.tab_fg(tab))
        background = as_rgb(self.draw_data.tab_bg(tab))
        for offset in range(height):
            screen.cursor.x, screen.cursor.y = 0, row + offset
            screen.cursor.fg, screen.cursor.bg = foreground, background
            screen.cursor.bold, screen.cursor.italic = False, False
            screen.draw(" " * screen.columns)
            screen.cursor.x = 0
            screen.draw(entry.indent)
            width = screen.columns - 1 - wcswidth(entry.indent)
            if offset == 0:
                screen.cursor.bold = not entry.window_id or entry.active
                if entry.attention:
                    screen.cursor.fg = ACCENT
                    screen.draw(ACTIVITY_MARKER)
                    screen.cursor.fg = foreground
                    width -= wcswidth(ACTIVITY_MARKER)
                screen.draw(fit(entry.title, width))
            else:
                muted = alpha_blend(
                    color_from_int(foreground >> 8),
                    color_from_int(background >> 8),
                    0.68,
                )
                screen.cursor.fg = as_rgb(color_as_int(muted))
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


TabBar.update_vertical = update_vertical
TabBar.window_drop_target_at = window_drop_target_at
handle_tab_bar_mouse.sidebar_original = original_mouse
on_window_drop.sidebar_original = original_drop
TabManager.handle_tab_bar_mouse = handle_tab_bar_mouse
TabManager.on_window_drop = on_window_drop


def draw_tab(
    draw_data, screen, tab, before, max_tab_length, index, is_last, extra_data
):
    # Kitty requires this entry point even though update_vertical draws groups.
    screen.draw(fit(title_for_tab(tab), max_tab_length))
    return screen.cursor.x
