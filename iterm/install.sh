#!/usr/bin/env bash
source ./script/utils.sh

e_header "Trying to configure iterm..."

# Check if iterm exists
if [ $(brew cask ls | grep "iterm2" | wc -l) -ne 1 ]; then
    e_error "iterm2 is not installed."
    exit 1
fi

defaults write com.googlecode.iterm2 PrefsCustomFolder -string "~/.dotfiles/iterm"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -int 1

if [ $? -ne 0 ]; then
    e_error "Configuration failed!"
    exit 1
fi
e_success "Success."
