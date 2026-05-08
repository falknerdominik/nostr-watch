#!/usr/bin/env bash
set -euo pipefail

# nostr-watch devcontainer feature test script
# Validates that all dependencies are installed and functional

echo "Testing nostr-watch feature installation..."

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

FAILED_TESTS=0
PASSED_TESTS=0

test_command() {
  local cmd="$1"
  local description="$2"
  
  if command -v "$cmd" >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} $description: $cmd found"
    PASSED_TESTS=$((PASSED_TESTS + 1))
    return 0
  else
    echo -e "${RED}✗${NC} $description: $cmd not found"
    FAILED_TESTS=$((FAILED_TESTS + 1))
    return 1
  fi
}

test_file() {
  local file="$1"
  local description="$2"
  
  if [ -f "$file" ]; then
    echo -e "${GREEN}✓${NC} $description: $file exists"
    PASSED_TESTS=$((PASSED_TESTS + 1))
    return 0
  else
    echo -e "${RED}✗${NC} $description: $file not found"
    FAILED_TESTS=$((FAILED_TESTS + 1))
    return 1
  fi
}

test_executable() {
  local file="$1"
  local description="$2"
  
  if [ -x "$file" ]; then
    echo -e "${GREEN}✓${NC} $description: $file is executable"
    PASSED_TESTS=$((PASSED_TESTS + 1))
    return 0
  else
    echo -e "${RED}✗${NC} $description: $file is not executable"
    FAILED_TESTS=$((FAILED_TESTS + 1))
    return 1
  fi
}

echo ""
echo "=== Dependency Tests ==="

# Test core dependencies
test_command "git" "Git version control"
test_command "curl" "HTTP client"
test_command "jq" "JSON processor"
test_command "awk" "Text processing"
test_command "date" "Date utility"
test_command "wc" "Word count utility"
test_command "mkfifo" "Named pipe utility"
test_command "find" "File search utility"

# Test task-spooler (tsp or ts)
if command -v tsp >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Task spooler: tsp found"
  PASSED_TESTS=$((PASSED_TESTS + 1))
  
  if tsp -S 1 >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Task spooler: tsp functional"
    PASSED_TESTS=$((PASSED_TESTS + 1))
  else
    echo -e "${RED}✗${NC} Task spooler: tsp not functional"
    FAILED_TESTS=$((FAILED_TESTS + 1))
  fi
elif command -v ts >/dev/null 2>&1; then
  echo -e "${GREEN}✓${NC} Task spooler: ts found"
  PASSED_TESTS=$((PASSED_TESTS + 1))
  
  if ts -S 1 >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Task spooler: ts functional"
    PASSED_TESTS=$((PASSED_TESTS + 1))
  else
    echo -e "${RED}✗${NC} Task spooler: ts not functional"
    FAILED_TESTS=$((FAILED_TESTS + 1))
  fi
else
  echo -e "${RED}✗${NC} Task spooler: neither tsp nor ts found"
  FAILED_TESTS=$((FAILED_TESTS + 2))
fi

# Test nak
test_command "nak" "Nostr Army Knife (nak)"

if command -v nak >/dev/null 2>&1; then
  NAK_VERSION=$(nak --version 2>&1 || echo "unknown")
  echo -e "${YELLOW}ℹ${NC}  nak version: $NAK_VERSION"
fi

echo ""
echo "=== nostr-watch Installation Tests ==="

# Test nostr-watch script
test_command "nostr-watch" "nostr-watch command"
test_file "/usr/local/bin/nostr-watch" "nostr-watch script file"
test_executable "/usr/local/bin/nostr-watch" "nostr-watch executable"

# Test version flag
if command -v nostr-watch >/dev/null 2>&1; then
  VERSION_OUTPUT=$(nostr-watch --version 2>&1 || echo "FAILED")
  if [[ "$VERSION_OUTPUT" == *"nostr-watch v"* ]]; then
    echo -e "${GREEN}✓${NC} nostr-watch version flag works: $VERSION_OUTPUT"
    PASSED_TESTS=$((PASSED_TESTS + 1))
  else
    echo -e "${RED}✗${NC} nostr-watch version flag failed: $VERSION_OUTPUT"
    FAILED_TESTS=$((FAILED_TESTS + 1))
  fi
fi

# Test help output
if command -v nostr-watch >/dev/null 2>&1; then
  HELP_OUTPUT=$(nostr-watch help 2>&1 || echo "")
  if [[ "$HELP_OUTPUT" == *"Usage:"* ]] || [[ "$HELP_OUTPUT" == *"start|stop|status"* ]]; then
    echo -e "${GREEN}✓${NC} nostr-watch help output works"
    PASSED_TESTS=$((PASSED_TESTS + 1))
  else
    echo -e "${YELLOW}⚠${NC}  nostr-watch help output unexpected (may still work)"
  fi
fi

echo ""
echo "=== Architecture Detection ==="

ARCH=$(uname -m)
echo -e "${YELLOW}ℹ${NC}  System architecture: $ARCH"

case "$ARCH" in
  x86_64|amd64)
    echo -e "${GREEN}✓${NC} Architecture: amd64 (supported)"
    PASSED_TESTS=$((PASSED_TESTS + 1))
    ;;
  aarch64|arm64)
    echo -e "${GREEN}✓${NC} Architecture: arm64 (supported)"
    PASSED_TESTS=$((PASSED_TESTS + 1))
    ;;
  *)
    echo -e "${YELLOW}⚠${NC}  Architecture: $ARCH (may not be supported)"
    ;;
esac

echo ""
echo "=== Summary ==="
echo -e "${GREEN}Passed:${NC} $PASSED_TESTS"
echo -e "${RED}Failed:${NC} $FAILED_TESTS"

if [ $FAILED_TESTS -eq 0 ]; then
  echo -e "\n${GREEN}✓ All tests passed!${NC}"
  echo ""
  echo "nostr-watch is ready to use."
  echo "Set NOSTR_PUBLIC_KEY environment variable and run: nostr-watch start"
  exit 0
else
  echo -e "\n${RED}✗ Some tests failed.${NC}"
  echo "Please check the installation."
  exit 1
fi
