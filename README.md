# dotfiles

My personal configuration files. Built on [Dotbot](https://github.com/anishathalye/dotbot) for cross-platform compatibility.

## Installation

For linux and macOS:
```bash
./install
```

For windows:
```powershell
.\install.ps1
```

## Updating

### Dotbot + Plugins

```bash
git submodule update --remote
```

### Misc
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
