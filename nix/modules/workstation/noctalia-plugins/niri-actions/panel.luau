local actions = {
  { label = "Toggle fullscreen", glyph = "arrows-maximize", command = "niri msg action fullscreen-window" },
  { label = "Toggle floating", glyph = "picture-in-picture", command = "niri msg action toggle-window-floating" },
  { label = "Toggle pair", glyph = "layout-columns", command = "niri-toggle-pair" },
  { label = "Cycle column width", glyph = "arrows-horizontal", command = "niri msg action switch-preset-column-width" },
  { label = "Move to next monitor", glyph = "device-desktop", command = "niri msg action move-window-to-monitor-next" },
  { label = "Show keyboard shortcuts", glyph = "keyboard", command = "niri msg action show-hotkey-overlay" },
}

local function runAction(action)
  local started = noctalia.runAsync(action.command, function(result)
    if result.exitCode == 0 then
      panel.close()
    else
      noctalia.notify("Niri actions", action.label .. " failed: " .. result.stderr)
    end
  end)
  if not started then
    noctalia.notify("Niri actions", "Could not start " .. action.label)
  end
end

function onOpen()
  local rows = {
    ui.row({ align = "center", gap = 8 }, {
      ui.label({
        text = "Niri actions",
        fontSize = 16,
        fontWeight = "bold",
        color = "primary",
        flexGrow = 1,
      }),
      ui.button({
        glyph = "close",
        glyphSize = 14,
        tooltip = "Close",
        variant = "default",
        controlSize = "sm",
        width = 32,
        onClick = function() panel.close() end,
      }),
    }),
  }

  for _, action in ipairs(actions) do
    table.insert(rows, ui.button({
      key = action.command,
      text = action.label,
      glyph = action.glyph,
      contentAlign = "start",
      onClick = function() runAction(action) end,
    }))
  end

  panel.render(ui.column({ gap = 12 }, rows))
end
