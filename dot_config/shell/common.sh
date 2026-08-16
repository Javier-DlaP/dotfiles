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
    if [ "$#" -eq 0 ]; then
        set -- sleep infinity
    fi

    case "$(uname -s)" in
        Darwin)
            caffeinate -dimsu "$@"
            ;;
        *)
            if command -v systemd-inhibit >/dev/null 2>&1; then
                systemd-inhibit --what=idle:sleep --who=keepawake --why="User request" "$@"
            else
                echo "keepawake: systemd-inhibit or macOS required." >&2
                return 1
            fi
            ;;
    esac
}

# ---------------------------------------------------------------------------
# FZF (completion + key bindings) for both bash and zsh
# ---------------------------------------------------------------------------
if command -v fzf >/dev/null 2>&1; then
    _fzf_shell=
    if [ -n "${ZSH_VERSION:-}" ]; then
        _fzf_shell=zsh
    else
        _fzf_shell=bash
    fi

    # Color theme for fzf in both shells (only when the user hasn't set one)
    case "${FZF_DEFAULT_OPTS:-}" in
        *--color*) ;;
        *)
            export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+${FZF_DEFAULT_OPTS} }--color=bg+:-1,pointer:blue,border:blue,header:blue,info:cyan,marker:yellow,prompt:cyan,hl:magenta,hl+:magenta,bg:-1,fg:-1"
            ;;
    esac

    if fzf "--${_fzf_shell}" >/dev/null 2>&1; then
        eval "$(fzf "--${_fzf_shell}")"
    else
        for _f in \
            "/usr/share/fzf/shell/key-bindings.${_fzf_shell}" \
            "/usr/share/fzf/shell/completion.${_fzf_shell}" \
            "/usr/share/fzf/key-bindings.${_fzf_shell}" \
            "/usr/share/fzf/completion.${_fzf_shell}"; do
            [ -r "$_f" ] && . "$_f"
        done
        unset _f
    fi
    unset _fzf_shell
fi

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