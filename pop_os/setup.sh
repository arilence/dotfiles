sudo apt-get update
sudo apt-get install gnome-tweaks

# There is no easy way to get the config ID from the GUI settings. The best way I found is to run a command that watches for config changes.
# Command: `dconf watch /`
# You can then use `gsettings list-keys [id]` to narrow down the correct domain if you're unsure about if the key is correct.

# Disable automatic screen brightness
# I found that the brightness increments to be too jarring
gsettings set org.gnome.settings-daemon.plugins.power ambient-enabled false

# Hide dock at bottom of screen, but show it when no application is maximized
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide true

# Set trackpad sensitivity
gsettings set org.gnome.desktop.peripherals.touchpad speed 0.45

# Set trackpad natural scrolling
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true

# Set mouse/trackpad acceleration profile to flat
gsettings set org.gnome.desktop.peripherals.mouse.accel-profile 'flat'

# Moves window buttons to the left (like macOS) and then also enables the maximize button
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:appmenu'

# Show battery percentage in menu bar
gsettings set org.gnome.desktop.interface show-battery-percentage true

# Makes Caps Lock act as Ctrl (requires gnome-tweaks)
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:ctrl_modifier']"

# Sets clock to 24 hour format
gsettings set org.gnome.desktop.interface clock-format '24h'

# Disable vertical workspaces (brings back horizontal workspaces)
# Similar to macOS spaces
gsettings set org.gnome.shell.disabled-extensions "['cosmic-workspaces@system76.com']"
