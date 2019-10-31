if test ! $(which gcc) || test ! $(which brew); then
  return
fi

# Assuming rbenv is already installed through homebrew
eval "$(rbenv init -)"
rbenv install --skip-existing 2.6.3
rbenv global 2.6.3

# Tmux plugin manager
[ ! -d "$HOME/.tmux/plugins/tpm" ] && git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
