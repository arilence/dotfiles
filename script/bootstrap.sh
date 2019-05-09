#!/usr/bin/env bash
# This script acts as a bootstrap for installation.
# It installs the necessary applications to unpack my dotfiles:
# - Homebrew
# - Commonly used Applications
source ./script/utils.sh

# Make sure that the command line tools are installed before continuing
if ! type_exists 'gcc'; then
  if [[ $OSTYPE =~ "darwin" ]]; then
    e_error "You must install the Xcode command line tools before continuing"
  else
    e_error "Hmm.. gcc was not found on this machine, that's very strange"
  fi
  exit 1
fi

# Install Homebrew for mac as a base for installing other applications
e_header "Trying to install Homebrew..."
if ! type_exists 'brew'; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    if [ $? -ne 0 ]; then
        e_error "HOMEBREW FAILED!"
        exit 1
    fi
else
    e_success "You already have Homebrew installed."
fi

# Install applications
e_header "Trying to install common applications..."
brew update
brew bundle
if [ $? -ne 0 ]; then
    e_error "APPLICATION INSTALLATION FAILED!"
    exit 1
fi
