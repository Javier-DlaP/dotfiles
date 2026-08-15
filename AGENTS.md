# AGENTS.md

chezmoi dotfiles supporting bash and zsh on macOS (brew) and Linux (apt/pacman).

## Conventions
- Source files map to targets: `dot_*` → `~/`, `dot_config/*` → `~/.config/*`.
- `dot_config/shell/common.sh` is **POSIX `sh`**, sourced by both bash and zsh.
  No bash-isms (arrays, `[[ ]]`, `&>`); branch on `$ZSH_VERSION` for shell-specific init.
- Manage files with `chezmoi` (use `--source .` when running from this repo).

## Packages
- Layout: `packages/<pm>/{core,bash,zsh}.txt` (apt/pacman) or `*.Brewfile` (brew).
- Bash uses `bash-completion` + `fzf`; zsh keeps autosuggestions/syntax-highlighting.
- macOS (brew) installs core + zsh only; Linux installs core + detected shell (`$SHELL`).

## Tests
- `./tests/test.sh` builds Docker images for debian/arch × {bash,zsh} and validates brew.
- Run it and expect all suites to pass.