sudo apt-get install -y gnome-tweaks

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
gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'flat'

# Keeps the trackpad enabled while typing
gsettings set org.gnome.desktop.peripherals.touchpad disable-while-typing false

# Moves window buttons to the left (like macOS) and then also enables the maximize button
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:appmenu'

# Makes Caps Lock act as Ctrl (requires gnome-tweaks)
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:ctrl_modifier']"

# Sets clock to 24 hour format
gsettings set org.gnome.desktop.interface clock-format '24h'

# Disable vertical workspaces (brings back horizontal workspaces)
# Similar to macOS spaces
gsettings set org.gnome.shell disabled-extensions "['cosmic-workspaces@system76.com']"

# Add keybindings for window management
gsettings set org.gnome.desktop.wm.keybindings maximize "['<Primary><Super>k']"
gsettings set org.gnome.desktop.wm.keybindings unmaximize "['<Primary><Super>j']"
gsettings set org.gnome.desktop.wm.keybindings move-to-center "['<Primary><Super>space']"
# Disable keybindings that used the same bindings as what window management is set to
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-up "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-down "[]"

# Disable keybindings for some default apps
gsettings set org.gnome.settings-daemon.plugins.media-keys email "[]"
gsettings set org.gnome.settings-daemon.plugins.media-keys help "[]"
gsettings set org.gnome.settings-daemon.plugins.media-keys home "[]"
gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "[]"
gsettings set org.gnome.settings-daemon.plugins.media-keys www "[]"
gsettings set org.gnome.shell.keybindings toggle-application-view "[]"

# Disable Pop OS's default Super-Space keybind
gsettings set org.gnome.desktop.wm.keybindings switch-input-source-backward "[]"
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "[]"

# Change "overview" shortcut to right super so that left super can be used for custom keybindings
gsettings set org.gnome.mutter overlay-key ""

# Set Super+Space to launch Rofi
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Super>space'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'rofi -modi drun -show drun'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Launch Rofi'
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/PopLaunch1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
