#!/usr/bin/env bash
source ./script/utils.sh

e_header "Trying to configure iterm..."

defaults write com.googlecode.iterm2 PrefsCustomFolder -string "${CWD}/iterm"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -int 1

if [ $? -ne 0 ]; then
    e_error "Configuration failed!"
    exit 1
fi
e_success "Success."
