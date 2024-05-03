# dotfiles

My personal configuration files.
As I only use macOS as my primary platform, these have not been tested to work on any other *nix platforms.

## Installation

This is **destructive**.

```sh
# TODO: Fail if `.config/` already exists

ln -sf "${PWD}/config" "${HOME}/.config"
ln -sf "${PWD}/zshenv" "${HOME}/.zshenv"
ln -sf "${PWD}/editorconfig" "${HOME}/.editorconfig"

# Must be run after creating symlinks or else ln will fail and complain about non-empty directory
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/.zprezto"

bash macos/install.sh
chsh -s /bin/zsh
```

## Updating
```bash
brew upgrade
zprezto-update
nvim --headless "+Lazy! update" +qa
nvim --headless "+MasonUpdate" +qa
mise up
```

## Completions
```bash
zprezto-build-cache
zprezto-clear-cache
```

## Inspiration
- https://github.com/knowler/dotfiles
- https://github.com/tcmmichaelb139/.dotfiles/
- https://github.com/mhanberg/.dotfiles
