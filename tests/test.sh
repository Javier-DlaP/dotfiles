#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; NC='\033[0m'
OVERALL=0

for distro in debian arch; do
    image="dotfiles-test-$distro"

    echo ""
    echo -e "${CYAN}=== Testing: $distro ===${NC}"

    echo -e "  Building Docker image ..."
    if docker build -t "$image" -f "$SCRIPT_DIR/Dockerfile.$distro" "$REPO_DIR" > /tmp/dotfiles-build-$distro.log 2>&1; then
        echo -e "  ${GREEN}Build OK${NC}"
    else
        echo -e "  ${RED}Build FAILED${NC}"
        echo "--- last 30 lines of build log ---"
        tail -30 "/tmp/dotfiles-build-$distro.log"
        OVERALL=1
        continue
    fi

    echo "  Running test suite in container ..."
    if docker run --rm "$image" 2>&1; then
        echo -e "  ${GREEN}Tests PASSED${NC}"
    else
        echo -e "  ${RED}Tests FAILED${NC}"
        OVERALL=1
    fi
done

echo ""
echo -e "${CYAN}=== Done ===${NC}"
exit $OVERALL