#!/usr/bin/env bash
if test ! $(which dockutil); then
  return
fi

# Setup the dock how I like it
dockutil --remove all --no-restart
dockutil --add '/Applications/Google Chrome.app' --no-restart
dockutil --add '/Applications/Spotify.app' --no-restart
dockutil --add '/Applications/Alacritty.app' --no-restart
dockutil --add '/Applications/Mailspring.app' --no-restart
dockutil --add '~/Downloads' --view grid --display folder --no-restart
killall Dock
