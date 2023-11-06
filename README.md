# dotfiles

My personal configuration files. Somehow they work together to make my life easier.
As I only use macOS as my primary platform, these have not been tested to work on any other *nix platforms.

## Installation

This is **destructive**.

```sh
for d in config/*/; do
  echo "$d"
  ln -sf "${PWD}/${d}" "${HOME}/.config"
done

ln -sf "${PWD}/zshenv" "${HOME}/.zshenv"
ln -sf "${PWD}/editorconfig" "${HOME}/.editorconfig"

bash macos/install.sh

git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/.zprezto"
chsh -s /bin/zsh
```

## Inspiration
- https://github.com/knowler/dotfiles
- https://github.com/tcmmichaelb139/.dotfiles/
- https://github.com/mhanberg/.dotfiles
