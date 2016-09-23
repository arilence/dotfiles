#!/bin/bash
source ./lib/utils.sh

# Make sure that the command line tools are installed before continuing
if ! type_exists 'gcc'; then
  e_error "You must install the Xcode command line tools before continuing"
  exit 1
fi

git submodule update --init --recursive


# '###############################################'
# 'Trying to install Applications with Homebrew...'
# '###############################################'
e_header "Trying to install Applications with Homebrew..."
seek_confirmation ""
if is_confirmed; then
  # Check if homebrew is installed
  if ! type_exists 'brew'; then
    e_header "Homebrew not found, Installing now..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi

  e_header "Make sure Homebrew has writable access to /usr/local (Requires Root)"
  sudo chown -R $(whoami) /usr/local
  brew update

  # Install application from Brewfile
  brew bundle
else
  printf "Skipped installing applications with Homebrew\n\n"
fi


# '####################################'
# 'Trying to install NodeJS packages...'
# '####################################'
e_header "Trying to install NodeJS packages..."
seek_confirmation ""
if is_confirmed; then
  if ! type_exists 'npm'; then
    e_error "Aborting... npm was not found."
  else
    packages="bower gulp yo n"
    npm install $packages --global --quiet
  fi
else
  printf "Skipped installing NodeJS packages\n\n"
fi


# '####################################'
# 'Trying to install Python apps...'
# '####################################'
e_header "Trying to install Python apps..."
seek_confirmation ""
if is_confirmed; then
  if ! type_exists 'pip2'; then
    e_error "Aborting... pip2 was not found."
  else
    pip2 install -r requirements-2.txt
  fi

  if ! type_exists 'pip3'; then
    e_error "Aborting... pip3 was not found."
  else
    pip3 install -r requirements-3.txt
  fi
else
  printf "Skipped installing NodeJS packages\n\n"
fi


# '##########################################'
# 'Trying to set OSX Defaults (Requires Root)'
# '##########################################'
e_header "Trying to set OSX Defaults (Requires Root)..."
seek_confirmation "Warning: This step may modify your OS X system defaults."
if is_confirmed; then
  bash ./osx/set-defaults.sh
  e_success "Done. Note that some of these changes require a logout/restart to take effect."
else
  printf "Skipped setting OSX Defaults\n\n"
fi


# '##########################'
# 'Trying to create Symbolic links...'
# '##########################'
e_header "Trying to create Symbolic links..."
seek_confirmation "This could overwrite pre-existing dotfiles"
if is_confirmed; then
  # Make sure that our symlinks work
  CWD=$(pwd)

  ln -sf ${CWD}/vim/* ~/.config/nvim/
  ln -sf ${CWD}/vim/* ~/.vim/
  ln -sf ${CWD}/vim/init.vim ~/.vimrc

  ln -sf ${CWD}/oh-my-zsh/zshenv ~/.zshenv
  ln -sf ${CWD}/oh-my-zsh/zshrc ~/.zshrc
  ln -sf ${CWD}/oh-my-zsh/config/* ~/.oh-my-zsh/custom/

  ln -sf ${CWD}/git/gitconfig ~/.gitconfig

  ln -sf ${CMD}/tmux/tmux.conf ~/.tmux.conf

  # For some odd reason, I can't use the ${CWD} variable in this command.
  ln -sf ~/dotfiles/sublime-text-3/* ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/
fi
