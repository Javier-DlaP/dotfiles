#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; NC='\033[0m'
OVERALL=0

run_dotfiles_test() {
    local distro="$1"
    local image="dotfiles-test-$distro"

    echo ""
    echo -e "${CYAN}=== Testing: $distro ===${NC}"

    echo -e "  Building Docker image ..."
    if docker build -t "$image" -f "$SCRIPT_DIR/Dockerfile.$distro" "$REPO_DIR" > "/tmp/dotfiles-build-$distro.log" 2>&1; then
        echo -e "  ${GREEN}Build OK${NC}"
    else
        echo -e "  ${RED}Build FAILED${NC}"
        echo "--- last 30 lines of build log ---"
        tail -30 "/tmp/dotfiles-build-$distro.log"
        OVERALL=1
        return 1
    fi

    echo "  Running test suite in container ..."
    if docker run --rm "$image" 2>&1; then
        echo -e "  ${GREEN}Tests PASSED${NC}"
    else
        echo -e "  ${RED}Tests FAILED${NC}"
        OVERALL=1
        return 1
    fi
}

run_brew_test() {
    local image="dotfiles-test-brew"

    echo ""
    echo -e "${CYAN}=== Testing: brew (Brewfile validation) ===${NC}"

    echo -e "  Building Docker image (installing packages via linuxbrew) ..."
    if docker build -t "$image" -f "$SCRIPT_DIR/Dockerfile.brew" "$REPO_DIR" > /tmp/dotfiles-build-brew.log 2>&1; then
        echo -e "  ${GREEN}Brewfile packages validated${NC}"
    else
        echo -e "  ${RED}Brewfile validation FAILED${NC}"
        echo "--- last 30 lines of build log ---"
        tail -30 "/tmp/dotfiles-build-brew.log"
        OVERALL=1
        return 1
    fi
}

main() {
    echo -e "${CYAN}chezmoi dotfiles - Docker test suite${NC}"

    for distro in debian arch; do
        run_dotfiles_test "$distro" || true
    done

    run_brew_test || true

    echo ""
    echo -e "${CYAN}=== Done ===${NC}"
    exit $OVERALL
}

main