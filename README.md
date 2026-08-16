# Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Contents

- **Shell**: `~/.bashrc`, `~/.zshrc` and shared config in `~/.config/shell/common.sh`
- **Starship**: prompt config in `~/.config/starship.toml`
- **Neovim**: LazyVim-based config under `~/.config/nvim/`
- **Packages**: per-OS install lists in `packages/` (`Arch.txt`, `Debian.txt`, `Brewfile` for macOS), applied via an onchange script

## Usage

```sh
chezmoi init --apply --source <path-to-this-repo>
```

On a new machine, bootstrap chezmoi and apply the repo:

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply Javier-DlaP
```

Package installation runs automatically after apply, detecting the OS
(Arch, Debian/Ubuntu, or macOS).

## Tests

Checks that config files exist, load cleanly in bash/zsh, and that starship
and zoxide work across shells. Docker-based tests for each supported OS live
in `tests/`.

```sh
tests/test.sh
```
