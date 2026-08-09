#!/bin/bash
set -e

export PATH="$HOME/.local/bin:$PATH"

PASS=0
FAIL=0
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

check() {
    local desc="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        echo -e "  ${GREEN}PASS${NC} $desc"
        PASS=$((PASS + 1))
    else
        echo -e "  ${RED}FAIL${NC} $desc"
        FAIL=$((FAIL + 1))
    fi
}

echo ""
echo "=== chezmoi dotfiles test suite ==="
echo ""

echo "--- File existence ---"
check "~/.bashrc exists"                     test -f "$HOME/.bashrc"
check "~/.zshrc exists"                      test -f "$HOME/.zshrc"
check "~/.config/shell/common.sh exists"     test -f "$HOME/.config/shell/common.sh"
check "~/.config/starship.toml exists"       test -f "$HOME/.config/starship.toml"
check "~/.config/nvim exists"                test -d "$HOME/.config/nvim"
check "~/.config/nvim/init.lua exists"       test -f "$HOME/.config/nvim/init.lua"

echo ""
echo "--- common.sh syntax: bash ---"
if bash -c '. "$HOME/.config/shell/common.sh"' 2>&1; then
    echo -e "  ${GREEN}PASS${NC} common.sh loads in bash without errors"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} common.sh loads in bash without errors"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "--- common.sh syntax: zsh ---"
if zsh -c '. "$HOME/.config/shell/common.sh"' 2>&1; then
    echo -e "  ${GREEN}PASS${NC} common.sh loads in zsh without errors"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} common.sh loads in zsh without errors"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "--- Binary checks ---"
check "starship is in PATH"                  command -v starship
check "zoxide is in PATH"                    command -v zoxide
check "starship runs"                        starship --version
check "zoxide runs"                          zoxide --version

echo ""
echo "--- Starship init in shells ---"
if bash -c 'eval "$(starship init bash)"' 2>&1; then
    echo -e "  ${GREEN}PASS${NC} starship init bash works"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} starship init bash works"
    FAIL=$((FAIL + 1))
fi

if zsh -c 'eval "$(starship init zsh)"' 2>&1; then
    echo -e "  ${GREEN}PASS${NC} starship init zsh works"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} starship init zsh works"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "--- Zoxide init in shells ---"
if bash -c 'eval "$(zoxide init bash)"' 2>&1; then
    echo -e "  ${GREEN}PASS${NC} zoxide init bash works"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} zoxide init bash works"
    FAIL=$((FAIL + 1))
fi

if zsh -c 'eval "$(zoxide init zsh)"' 2>&1; then
    echo -e "  ${GREEN}PASS${NC} zoxide init zsh works"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} zoxide init zsh works"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "--- Full bashrc load ---"
if bash --rcfile "$HOME/.bashrc" -ic 'exit 0' 2>&1; then
    echo -e "  ${GREEN}PASS${NC} bashrc loads without errors"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} bashrc loads without errors"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "--- Full zshrc load ---"
if zsh -c 'ZDOTDIR="$HOME" . "$HOME/.zshrc"' 2>&1; then
    echo -e "  ${GREEN}PASS${NC} zshrc loads without errors"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} zshrc loads without errors"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "--- Neovim config ---"
check "init.lua is readable" test -r "$HOME/.config/nvim/init.lua"
if head -1 "$HOME/.config/nvim/init.lua" 2>/dev/null | grep -qi 'lazy'; then
    echo -e "  ${GREEN}PASS${NC} init.lua contains lazy.nvim reference"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} init.lua contains lazy.nvim reference"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "========================================="
echo -e "Results: ${GREEN}${PASS} passed${NC}, ${RED}${FAIL} failed${NC}"
echo "========================================="

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
exit 0