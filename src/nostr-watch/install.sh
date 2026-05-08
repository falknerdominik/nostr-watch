#!/usr/bin/env bash
set -euo pipefail

# nostr-watch devcontainer feature installation script
# Installs dependencies and the nostr-watch watcher script

echo "Installing nostr-watch feature..."

# Detect architecture
ARCH="${TARGETARCH:-$(uname -m)}"
case "$ARCH" in
  amd64|x86_64)
    NAK_ARCH="amd64"
    ;;
  arm64|aarch64)
    NAK_ARCH="arm64"
    ;;
  *)
    echo "ERROR: Unsupported architecture: $ARCH" >&2
    echo "nostr-watch supports: amd64 (x86_64), arm64 (aarch64)" >&2
    exit 1
    ;;
esac

echo "Detected architecture: $ARCH (using nak binary for $NAK_ARCH)"

# Check which dependencies are missing
MISSING_PACKAGES=()
for pkg in git curl jq task-spooler; do
  if [ "$pkg" = "task-spooler" ]; then
    # task-spooler provides 'tsp' command
    if ! command -v tsp >/dev/null 2>&1; then
      MISSING_PACKAGES+=("$pkg")
    fi
  else
    if ! command -v "$pkg" >/dev/null 2>&1; then
      MISSING_PACKAGES+=("$pkg")
    fi
  fi
done

# Only install if there are missing packages
if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
  echo "Installing missing system dependencies: ${MISSING_PACKAGES[*]}..."
  # Update package list (may need fresh lists if they were cleaned)
  apt-get update -qq || true
  DEBIAN_FRONTEND=noninteractive apt-get install -yq \
    "${MISSING_PACKAGES[@]}" \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
else
  echo "All system dependencies already installed (git, curl, jq, task-spooler)."
fi

# Install or update nak (Nostr Army Knife)
NAK_VERSION="v0.19.8"
NAK_BINARY="nak-${NAK_VERSION}-linux-${NAK_ARCH}"
NAK_URL="https://github.com/fiatjaf/nak/releases/download/${NAK_VERSION}/${NAK_BINARY}"

# Check if nak is already installed with correct architecture
NAK_NEEDS_INSTALL=true
if command -v nak >/dev/null 2>&1; then
  # Try to run nak to see if it's the right architecture
  if nak --version >/dev/null 2>&1; then
    echo "nak is already installed and working."
    NAK_NEEDS_INSTALL=false
  else
    echo "nak exists but is wrong architecture or corrupted, reinstalling..."
  fi
fi

if [ "$NAK_NEEDS_INSTALL" = "true" ]; then
  echo "Downloading nak ${NAK_VERSION} for ${NAK_ARCH}..."
  curl -sSL "$NAK_URL" -o /usr/local/bin/nak
  
  # Make nak executable
  chmod +x /usr/local/bin/nak
  
  # Verify nak installation
  if ! command -v nak >/dev/null 2>&1; then
    echo "ERROR: nak installation failed" >&2
    exit 1
  fi
  
  echo "nak installed successfully: $(nak --version 2>&1 || echo 'unknown version')"
fi

# Copy nostr-watch script to /usr/local/bin
echo "Installing nostr-watch script..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "${SCRIPT_DIR}/nostr-watch.sh" ]; then
  echo "ERROR: nostr-watch.sh not found in ${SCRIPT_DIR}" >&2
  echo "Available files:" >&2
  ls -la "${SCRIPT_DIR}" >&2
  exit 1
fi

cp "${SCRIPT_DIR}/nostr-watch.sh" /usr/local/bin/nostr-watch
chmod +x /usr/local/bin/nostr-watch

# Verify nostr-watch installation
if ! command -v nostr-watch >/dev/null 2>&1; then
  echo "ERROR: nostr-watch installation failed" >&2
  exit 1
fi

# Verify all dependencies
echo "Verifying dependencies..."
MISSING_DEPS=()

for cmd in git curl jq tsp nak nostr-watch; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    MISSING_DEPS+=("$cmd")
  fi
done

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
  echo "ERROR: Missing dependencies: ${MISSING_DEPS[*]}" >&2
  exit 1
fi

echo "✓ All dependencies installed successfully"
echo "✓ nostr-watch feature installation complete"
echo ""
echo "Usage: nostr-watch {start|stop|status}"
echo "Environment variables: NOSTR_PUBLIC_KEY, NOSTR_RELAYS, NOSTR_WATCH_* (see README)"
