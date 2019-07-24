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
if test ! $(which brew); then
  if  [[ $OSTYPE =~ "darwin" ]]; then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  elif [[ $OSTYPE =~ "linux" ]]; then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"
  else
    e_error "Your OS is not supposed"
    exit 1
  fi
  if [ $? -ne 0 ]; then
    e_error "Brew failed to install!"
    exit 1
  fi
else
  e_success "Brew is already installed."
fi

# Install applications
e_header "Trying to install common applications..."
export HOMEBREW_CASK_OPTS='--appdir=/Applications'
brew update
brew upgrade

# Tap brew repositories
brew tap 'caskroom/cask'
brew tap 'homebrew/bundle'
brew tap 'neovim/neovim'
brew tap 'thoughtbot/formulae'

# Install brew packages
brew install coreutils
brew install ctags
brew install fzy
brew install git
brew install git-lfs
brew install gnupg2
brew install neovim
brew install node
brew install openssl
brew install pinentry-mac
brew install python3
brew install ripgrep
brew install tmux
brew install yarn

# Install caskroom packages
brew cask install '1password6'
brew cask install 'bartender'
brew cask install 'docker'
brew cask install 'dropbox'
brew cask install 'google-chrome-dev'
brew cask install 'gpg-suite'
brew cask install 'istat-menus'
brew cask install 'keepingyouawake'
brew cask install 'mailspring'
brew cask install 'spotify'

# Remove outdated version
brew cleanup
