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
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias df='df -h'
alias du='du -h'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias mkdir='mkdir -pv'
alias diff='diff --color=auto'

if command -v free >/dev/null 2>&1; then
    alias free='free -h'
fi

if command -v bat >/dev/null 2>&1; then
    alias cat='bat --paging=never'
fi

if command -v eza >/dev/null 2>&1; then
    alias ls='eza'
    alias tree='eza --tree'
elif command -v exa >/dev/null 2>&1; then
    alias ls='exa'
    alias tree='exa --tree'
fi

if command -v fd >/dev/null 2>&1; then
    alias find='fd'
elif command -v fdfind >/dev/null 2>&1; then
    alias find='fdfind'
fi

# ---------------------------------------------------------------------------
# Git Aliases
# ---------------------------------------------------------------------------
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gco='git checkout'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate'
alias gp='git push'
alias gpl='git pull'
alias gs='git status'
alias gst='git stash'
alias gsp='git stash pop'

# ---------------------------------------------------------------------------
# Functions
# ---------------------------------------------------------------------------
mkcd() {
    mkdir -pv "$1" && cd "$1" || return
}

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

cht() {
    curl -s "cheat.sh/$*"
}

# ---------------------------------------------------------------------------
# FZF (bash key-bindings and completions only)
# ---------------------------------------------------------------------------
if command -v fzf >/dev/null 2>&1; then
    if [ -n "${BASH_VERSION:-}" ]; then
        for f in \
            /usr/share/doc/fzf/examples/key-bindings.bash \
            /usr/share/fzf/key-bindings.bash \
            /usr/share/fzf/shell/key-bindings.bash; do
            [ -f "$f" ] && { . "$f"; break; }
        done
        for f in \
            /usr/share/doc/fzf/examples/completion.bash \
            /usr/share/fzf/completion.bash \
            /usr/share/bash-completion/completions/fzf; do
            [ -f "$f" ] && { . "$f"; break; }
        done
    fi
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
    export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {}'"
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