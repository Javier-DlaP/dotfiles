#!/bin/sh
# shellcheck shell=sh
# Shared shell configuration sourced by both bash and zsh

export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-nvim}"
export PAGER="${PAGER:-less}"
export LANG="${LANG:-en_US.UTF-8}"

# ---------------------------------------------------------------------------
# Path
# ---------------------------------------------------------------------------
case "$(uname -s)" in
    Linux)
        PATH="$HOME/.local/bin:$PATH"
        ;;
    Darwin)
        PATH="/opt/homebrew/bin:$HOME/.local/bin:$PATH"
        ;;
esac
export PATH

# ---------------------------------------------------------------------------
# Common Aliases
# ---------------------------------------------------------------------------
alias ll='ls -alFh'
alias keepawake='caffeinate -dimsu'
alias oc='opencode'

# ---------------------------------------------------------------------------
# Functions
# ---------------------------------------------------------------------------
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2|*.tbz2) tar xjvf "$1" ;;
            *.tar.gz|*.tgz)   tar xzvf "$1" ;;
            *.tar.xz)         tar xJvf "$1" ;;
            *.tar.zst)        tar --zstd -xvf "$1" ;;
            *.bz2)            bunzip2 "$1" ;;
            *.gz)             gunzip "$1" ;;
            *.tar)            tar xvf "$1" ;;
            *.zip)            unzip "$1" ;;
            *.rar)            unrar x "$1" ;;
            *.7z)             7z x "$1" ;;
            *)                echo "extract: unknown archive type: $1" ;;
        esac
    else
        echo "extract: $1 is not a valid file"
    fi
}

keepawake() {
    local cmd=("${@:-sleep}" "infinity")
    [[ $# -gt 0 ]] && cmd=("$@")

    if [[ "$OSTYPE" == "darwin"* ]]; then
        caffeinate -dimsu "${cmd[@]}"
    elif command -v systemd-inhibit &>/dev/null; then
        systemd-inhibit --what=idle:sleep --who="keepawake" --why="User request" "${cmd[@]}"
    else
        echo "keepawake: systemd-inhibit or macOS required." >&2
        return 1
    fi
}

# ---------------------------------------------------------------------------
# Starship Prompt
# ---------------------------------------------------------------------------
if command -v starship >/dev/null 2>&1; then
    if [ -n "${ZSH_VERSION:-}" ]; then
        eval "$(starship init zsh)"
    else
        eval "$(starship init bash)"
    fi
fi

# ---------------------------------------------------------------------------
# Zoxide
# ---------------------------------------------------------------------------
if command -v zoxide >/dev/null 2>&1; then
    if [ -n "${ZSH_VERSION:-}" ]; then
        eval "$(zoxide init zsh --cmd cd)"
    else
        eval "$(zoxide init bash --cmd cd)"
    fi
fi