#!/usr/bin/env zsh

# Install Vim-plug
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Copy existing vimrc to nvim's expected config directory
mkdir -p ~/.config/nvim
cp ./init.vim ~/.config/nvim/init.vim

# Install vim-plug plugins
nvim +PlugInstall +qall


