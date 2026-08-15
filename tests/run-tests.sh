#!/bin/bash
set -e

export PATH="$HOME/.local/bin:$PATH"

case "${SHELL:-}" in
    *zsh) SHELL_NAME=zsh ;;
    *)    SHELL_NAME=bash ;;
esac

PASS=0
FAIL=0
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
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
echo "  Default shell under test: ${CYAN}${SHELL_NAME}${NC}"
echo "  (SHELL=${SHELL:-unset})"
echo ""

echo "--- File existence ---"
check "~/.bashrc exists"                     test -f "$HOME/.bashrc"
check "~/.zshrc exists"                      test -f "$HOME/.zshrc"
check "~/.config/shell/common.sh exists"     test -f "$HOME/.config/shell/common.sh"
check "~/.config/starship.toml exists"       test -f "$HOME/.config/starship.toml"
check "~/.config/nvim exists"                test -d "$HOME/.config/nvim"
check "~/.config/nvim/init.lua exists"       test -f "$HOME/.config/nvim/init.lua"

echo ""
echo "--- Neovim config ---"
check "init.lua is readable"                 test -r "$HOME/.config/nvim/init.lua"
if grep -qi 'lazy.nvim' "$HOME/.config/nvim/init.lua"; then
    echo -e "  ${GREEN}PASS${NC} init.lua bootstraps lazy.nvim"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} init.lua bootstraps lazy.nvim"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "--- common.sh loads in default shell ($SHELL_NAME) ---"
if "$SHELL_NAME" -c '. "$HOME/.config/shell/common.sh"' 2>&1; then
    echo -e "  ${GREEN}PASS${NC} common.sh loads in ${SHELL_NAME} without errors"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} common.sh loads in ${SHELL_NAME} without errors"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "--- Binary checks ---"
check "starship is in PATH"                  command -v starship
check "zoxide is in PATH"                    command -v zoxide
check "fzf is in PATH"                       command -v fzf
check "starship runs"                        starship --version
check "zoxide runs"                          zoxide --version
check "fzf runs"                             fzf --version

echo ""
echo "--- Shell integration in default shell ($SHELL_NAME) ---"
if "$SHELL_NAME" -c 'eval "$(starship init '"$SHELL_NAME"')"' 2>&1; then
    echo -e "  ${GREEN}PASS${NC} starship init ${SHELL_NAME} works"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} starship init ${SHELL_NAME} works"
    FAIL=$((FAIL + 1))
fi

if "$SHELL_NAME" -c 'eval "$(zoxide init '"$SHELL_NAME"' --cmd cd)"' 2>&1; then
    echo -e "  ${GREEN}PASS${NC} zoxide init ${SHELL_NAME} works"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} zoxide init ${SHELL_NAME} works"
    FAIL=$((FAIL + 1))
fi

if "$SHELL_NAME" -c '. "$HOME/.config/shell/common.sh"' 2>&1 && \
   "$SHELL_NAME" -c 'command -v fzf >/dev/null 2>&1'; then
    echo -e "  ${GREEN}PASS${NC} fzf integration (completion + key bindings) loads in ${SHELL_NAME}"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} fzf integration (completion + key bindings) loads in ${SHELL_NAME}"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "--- Full rc load (default shell: $SHELL_NAME) ---"
if "$SHELL_NAME" -c 'source "$HOME/.'"$SHELL_NAME"'rc"' 2>&1; then
    echo -e "  ${GREEN}PASS${NC} ~/.${SHELL_NAME}rc loads without errors"
    PASS=$((PASS + 1))
else
    echo -e "  ${RED}FAIL${NC} ~/.${SHELL_NAME}rc loads without errors"
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