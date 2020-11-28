#!/usr/bin/env bash

# TODO: support argument flags
# --force or -f
# --all or -a
# --modules=vim,tmux,zsh or -m=vim,tmux,zsh

printf " ___     ___   ______  _____  ____  _        ___  _____
|   \   /   \ |      ||   __||    || |      /  _]/ ___/
|  D \ |  O  ||_|  |_||  |_   |  | | |___  /   _]\__  |
|     ||     |  |  |  |   _]  |  | |     ||   [_ /  \ |
|_____| \___/   |__|  |__|   |____||_____||_____| \___|

                                            @ maybeinit\n\n"

# Variables that are available for use inside modules
DOTFILES_HOME=$(pwd -P)

# Variables that modules may change to signal information flow
DOTFILES_RESTART_TERMINAL=false

install_homebrew() {
  if test ! $(which gcc); then
    xcode-select --install
    if [ $? -ne 0 ]; then
      printf "GCC failed to install near $LINENO\n"
      exit $?
    fi
  fi

  if test ! $(which brew); then
    if [[ $OSTYPE =~ "darwin" ]]; then
      ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    elif [[ $OSTYPE =~ "linux" ]]; then
      ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"
    fi
    if [ $? -ne 0 ]; then
      printf "Brew failed to install near $LINENO\n"
      exit $?
    fi
  fi
}

install_zsh() {
  if test ! $(which zsh); then
    brew install zsh
    if [ $? -ne 0 ]; then
      printf "Zsh failed to install near line $LINENO\n"
      exit $?
    fi
  fi
}

# Given a src and dest, creates a symlink.
# Eventually it will be less destructive and prompt the user for overwriting files.
# Currently though, THIS IS DESTRUCTIVE.
#
# Arguments:
#    $1 = which file should be linked
#    $2 = where the file should be linked to
create_symlink() {
  src=$1
  dest=$2
  ln -sf $src $dest
}

# Loops through a specified directory for every file appened with `.symlink` and symlinks it to $HOME.
# Each file is assumed to be prepended with `.` when being link.
#
# Arguments:
#    $1 = name of the module / directory that will be scanned
setup_symlink() {
  MODULE_NAME=$1

  # Only link if symlink files exist
  for i in $DOTFILES_HOME/$MODULE_NAME/*.symlink; do
    ! test -f "$i" && return && break
  done

  symlinks=$(ls $DOTFILES_HOME/$MODULE_NAME/*.symlink)
  for src in $symlinks; do
    create_symlink $src "$HOME/.$(basename "${src%.*}")"
  done
}

# Reads the file `symlink` and creates links specified by each line.
# Each line of `symlink` is assumed to be a `src:dest` pair.
# Where `src` is the filename inside the module, and `dest` is a absolute path
#
# Arguments:
#    $1 = name of the module / directory that will be scanned
setup_symlink_advanced() {
  MODULE_NAME=$1
  SRC=$DOTFILES_HOME/$MODULE_NAME/symlink
  if [ ! -f $SRC ]; then
    return
  fi

  # Loops through each line of a file to create src and dest pairs
  while IFS= read -r line; do
    string=$line
    separator=':'

    tmp=${string//"$separator"/$'\2'}
    IFS=$'\2' read -a arr <<< "$tmp"
    create_symlink $DOTFILES_HOME/$MODULE_NAME/${arr[0]} $HOME/${arr[1]}
  done < "$SRC"
}

install_modules() {
  # BUG: directories with spaces will be split into two seperate array elements
  # i.e. "two words/" will become "two/" and "words/"
  DIRECTORIES=$(ls -d */)
  for MODULE_NAME in $DIRECTORIES; do
    # Ignore certain directories/modules
    # TODO: Read in CLI arguments to dynamically ignore modules
    if [[ "$MODULE_NAME" =~ "bin"
       || "$MODULE_NAME" =~ "functions"
       ]]; then
      continue
    fi

    printf "Installing module: $MODULE_NAME\n"

    # Setup symlinks
    setup_symlink $MODULE_NAME
    setup_symlink_advanced $MODULE_NAME

    # Only run install scripts which exist in modules
    [ -f $MODULE_NAME/install.sh ] && source $MODULE_NAME/install.sh
  done
}

# Let's do this.
install_homebrew
install_zsh
install_modules

printf "Finished!\n"
if [ $DOTFILES_RESTART_TERMINAL = true ]; then
  printf "Please restart your terminal so all changes may be applied\n"
fi
