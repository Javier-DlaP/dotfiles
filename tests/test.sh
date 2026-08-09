#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

TESTS=("debian" "arch")
RESULTS=()

run_test() {
    local name="$1"
    local dockerfile="$SCRIPT_DIR/Dockerfile.$name"
    local image_tag="dotfiles-test-$name"

    echo ""
    echo -e "${CYAN}====================================${NC}"
    echo -e "${CYAN}  Building and testing: $name${NC}"
    echo -e "${CYAN}====================================${NC}"
    echo ""

    echo -e "  Building Docker image dotfiles-test-$name ..."
    if docker build -t "$image_tag" -f "$dockerfile" "$REPO_DIR" 2>&1; then
        echo -e "  ${GREEN}Build succeeded${NC}"
    else
        echo -e "  ${RED}Build FAILED for $name${NC}"
        RESULTS+=("$name: BUILD FAILED")
        return 1
    fi

    echo ""
    echo "  Running test suite in container ..."
    if docker run --rm "$image_tag" 2>&1; then
        echo -e "  ${GREEN}All tests PASSED for $name${NC}"
        RESULTS+=("$name: PASSED")
    else
        echo -e "  ${RED}Tests FAILED for $name${NC}"
        RESULTS+=("$name: FAILED")
        return 1
    fi
}

main() {
    echo -e "${CYAN}chezmoi dotfiles - Docker test suite${NC}"
    echo ""

    local overall=0
    for t in "${TESTS[@]}"; do
        run_test "$t" || overall=1
    done

    echo ""
    echo -e "${CYAN}====================================${NC}"
    echo -e "${CYAN}  Summary${NC}"
    echo -e "${CYAN}====================================${NC}"
    for r in "${RESULTS[@]}"; do
        if echo "$r" | grep -q "PASSED$"; then
            echo -e "  ${GREEN}$r${NC}"
        else
            echo -e "  ${RED}$r${NC}"
        fi
    done
    echo ""
    exit $overall
}

main