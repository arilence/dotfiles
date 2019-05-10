#!/usr/bin/env bash
source ./script/utils.sh

e_header "Trying to configure the Dock..."

dockutil --remove all --no-restart
dockutil --add '/Applications/Google Chrome.app' --no-restart
dockutil --add '/Applications/Spotify.app' --no-restart
dockutil --add '/Applications/Alacritty.app' --no-restart
dockutil --add '/Applications/Mailspring.app' --no-restart
dockutil --add '~/Downloads' --view grid --display folder --no-restart
killall Dock

if [ $? -ne 0 ]; then
    e_error "Configuration failed!"
    exit 1
fi
e_success "Success."
