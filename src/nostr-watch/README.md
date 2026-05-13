# nostr-watch DevContainer Feature

Auto-start Nostr event watcher that triggers agent workflows on incoming events. Monitors Nostr relays for events (like NIP-17 DMs) and executes custom agent commands via handoff files.

## Features

- **Multi-platform support**: Works on arm64 (Apple Silicon, Raspberry Pi) and amd64 (x86_64)
- **Auto-installation**: Installs all dependencies (nak, jq, task-spooler) automatically
- **Clean environment variables**: Uses `NOSTR_WATCH_*` prefix to avoid conflicts
- **Auto-start**: Optionally starts watching on container startup
- **Cleanup management**: Automatic cleanup of old files with configurable retention
- **Agent integration**: Executes custom commands when events arrive

## Quick Start

To run nostr-watch from the command line with NIP-17 sender filtering:

```bash
# Set your bot's identity
export NOSTR_PUBLIC_KEY="npub1your_bot_pubkey..."
export NOSTR_SECRET_KEY="nsec1your_bot_secret_key..."

# Configure which senders are allowed to trigger your agent
export NOSTR_WATCH_NIP17_ALLOWED_SENDERS="npub1allowed_sender..."

# Set event kinds to monitor (1059 = NIP-17 gift-wrapped DMs)
export NOSTR_WATCH_KINDS="1059"

# Start the watcher
nostr-watch start
```

This configuration enables **NIP-17 prefiltering** (default behavior):
- Decrypts kind 1059 gift-wrapped messages using your `NOSTR_SECRET_KEY`
- Verifies the real sender inside the encrypted envelope
- Only accepts messages from senders in `NOSTR_WATCH_NIP17_ALLOWED_SENDERS`
- Passes verified sender metadata to your agent in the handoff file

To check status:
```bash
nostr-watch status
```

To stop:
```bash
nostr-watch stop
```

## Usage

### Minimal Configuration

Add to your `devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/falknerdominik/nostr-watch/nostr-watch:1": {}
  }
}
```

Set required environment variables in your `docker-compose.yml`:

```yaml
services:
  devcontainer:
    env_file:
      - .env  # Contains NOSTR_PUBLIC_KEY
```

### Full Configuration

```json
{
  "features": {
    "ghcr.io/falknerdominik/nostr-watch/nostr-watch:1": {
      "autoStart": true,
      "kinds": "1059",
      "relays": "wss://relay.damus.io wss://nos.lol wss://relay.snort.social",
      "retentionDays": "7",
      "maxFilesPerDir": "1000",
      "agentCmd": "cat"
    }
  }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `autoStart` | boolean | `true` | Automatically start the watcher when container starts |
| `kinds` | string | `"1059"` | Space-separated Nostr event kinds to monitor (1059 = NIP-17 gift-wrapped DMs) |
| `relays` | string | `"wss://relay.damus.io wss://nos.lol wss://relay.snort.social"` | Space-separated relay WebSocket URLs |
| `retentionDays` | string | `"7"` | Days to retain handoff/seen files (-1 to disable) |
| `maxFilesPerDir` | string | `"1000"` | Max files before emergency cleanup (-1 to disable) |
| `agentCmd` | string | `"cat"` | Command to execute when events arrive (receives handoff file path as argument) |

## Environment Variables

### Required (Ecosystem Standard)

These must be set in your environment (via `.env` file or docker-compose):

**⚠️ NIP-17 Decryption**: By default, `NOSTR_WATCH_NIP17_PREFILTER=1` is enabled, which decrypts and verifies NIP-17 gift-wrapped messages before queueing them. This requires `NOSTR_SECRET_KEY` to be set. If you only want to receive wake-up notifications without decryption, set `NOSTR_WATCH_NIP17_PREFILTER=0`.

| Variable | Description | Example |
|----------|-------------|---------|
| `NOSTR_PUBLIC_KEY` | Your Nostr public key (npub or hex format) | `npub14npkpm...` or `acc360ed...` |
| `NOSTR_SECRET_KEY` | Your Nostr secret key (required when `NOSTR_WATCH_NIP17_PREFILTER=1`) | `nsec1...` or hex secret key |

**⚠️ SECURITY WARNING**: Never put `NOSTR_SECRET_KEY` or `NOSTR_PUBLIC_KEY` directly in `devcontainer.json`. Always use environment variables via `.env` files or docker-compose `env_file`.

### Optional (Ecosystem Standard)

| Variable | Description | Default |
|----------|-------------|---------|
| `NOSTR_RELAYS` | Space-separated relay URLs | `wss://relay.damus.io wss://nos.lol wss://relay.snort.social` |

### Optional (Tool-Specific)

All nostr-watch configuration uses the `NOSTR_WATCH_*` prefix:

| Variable | Description | Default |
|----------|-------------|---------|
| `NOSTR_WATCH_KINDS` | Event kinds to monitor | `1059` |
| `NOSTR_WATCH_SINCE` | Lower bound timestamp (unix seconds) for event intake | Script start time minus 60 seconds |
| `NOSTR_WATCH_ALLOWED_SENDERS` | Comma-separated allowed sender pubkeys | _(empty)_ |
| `NOSTR_WATCH_NIP17_PREFILTER` | Enable NIP-17 decrypt/verify before queueing (0 or 1) | `1` |
| `NOSTR_WATCH_NIP17_ALLOWED_SENDERS` | Real NIP-17 sender allowlist (hex or npub1, comma/space-separated) | _(empty, required if NIP17_PREFILTER=1)_ |
| `NOSTR_WATCH_NIP17_ALLOWED_RUMOR_KINDS` | Allowed inner rumor kinds for NIP-17 messages | `14 15` |
| `NOSTR_WATCH_NIP17_REQUIRE_INNER_PTAG` | Require inner rumor to p-tag receiver (0 or 1) | `1` |
| `NOSTR_WATCH_NIP17_MARK_REJECTED_SEEN` | Mark rejected NIP-17 events as seen to avoid reprocessing (0 or 1) | `1` |
| `NOSTR_WATCH_STATE_DIR` | State directory path | `.nostr-watch` |
| `NOSTR_WATCH_LOG_FILE` | Log file path | `$STATE_DIR/watcher.log` |
| `NOSTR_WATCH_LOG_MAX_SIZE` | Max log size in bytes | `1048576` (1MB) |
| `NOSTR_WATCH_START_MODE` | Start mode: `foreground` or `daemon` | `daemon` |
| `NOSTR_WATCH_RECONNECT_SECONDS` | Reconnect delay on errors | `5` |
| `NOSTR_WATCH_HANDOFF_RETENTION_DAYS` | Handoff file retention | `7` |
| `NOSTR_WATCH_SEEN_RETENTION_DAYS` | Seen marker retention | `7` |
| `NOSTR_WATCH_CLEANUP_INTERVAL` | Cleanup interval in seconds | `3600` |
| `NOSTR_WATCH_MAX_FILES_PER_DIR` | Emergency cleanup threshold | `1000` |
| `NOSTR_WATCH_AGENT_CMD` | Agent command to execute | `cat` |

## Example Setup

### 1. Create `.env` file (DO NOT COMMIT)

```bash
# === Nostr Identity (ecosystem standard) ===
# Required: Keep these secret!
NOSTR_SECRET_KEY=nsec1...
NOSTR_PUBLIC_KEY=npub1_or_hex_your_public_key_here

# === Nostr Configuration (ecosystem standard) ===
# Optional: Used by multiple Nostr tools
NOSTR_RELAYS=wss://relay.damus.io wss://nos.lol

# === nostr-watch Configuration (tool-specific) ===
# Optional: Override feature defaults
NOSTR_WATCH_KINDS=1059

# Optional: override lower bound for events (unix seconds)
# Default is script start time minus 60 seconds
# NOSTR_WATCH_SINCE=1715412000

# NIP-17 Configuration (enabled by default)
# Allowlist of real NIP-17 sender pubkeys (hex or npub1, comma or space-separated)
# Required when NOSTR_WATCH_NIP17_PREFILTER=1 (default)
NOSTR_WATCH_NIP17_ALLOWED_SENDERS=npub1allowed_sender1,npub1allowed_sender2

# To disable NIP-17 prefiltering and just receive wake-up notifications:
# NOSTR_WATCH_NIP17_PREFILTER=0

NOSTR_WATCH_STATE_DIR=/workspace/.nostr-watch
NOSTR_WATCH_AGENT_CMD=/workspace/scripts/my-agent.sh
NOSTR_WATCH_HANDOFF_RETENTION_DAYS=7
NOSTR_WATCH_SEEN_RETENTION_DAYS=7
NOSTR_WATCH_MAX_FILES_PER_DIR=1000
```

### 2. Add to `.gitignore`

```
.env
.data/
```

### 3. Configure docker-compose.yml

```yaml
services:
  devcontainer:
    env_file:
      - .env
```

### 4. Configure devcontainer.json

```json
{
  "name": "My Project",
  "dockerComposeFile": "./docker-compose.yml",
  "service": "devcontainer",
  "features": {
    "ghcr.io/falknerdominik/nostr-watch/nostr-watch:1": {
      "autoStart": true
    }
  }
}
```

## Commands

Once installed, use the `nostr-watch` command:

```bash
# Start the watcher (daemon mode)
nostr-watch start

# Stop the watcher
nostr-watch stop

# Check status
nostr-watch status

# Check status (JSON format)
nostr-watch status --json

# View logs (follow mode)
nostr-watch logs

# View last N log lines
nostr-watch logs 50

# Check relay connectivity
nostr-watch check

# Show version
nostr-watch --version
```

## How It Works

1. **Monitor**: Watches configured Nostr relays for events matching your pubkey and kinds
2. **Detect**: When an event arrives, creates a handoff file with event metadata
3. **Execute**: Runs your configured agent command with the handoff file path
4. **Track**: Marks events as seen to prevent duplicate processing
5. **Cleanup**: Automatically removes old handoff/seen files based on retention policy

### Handoff Files

When an event is detected, nostr-watch creates a markdown file in `$STATE_DIR/handoffs/`:

```markdown
# Nostr wake-up

A Nostr event addressed to this identity was detected.

- Event ID: `abc123...`
- Kind: `1059`
- Visible pubkey: `xyz789...`
- Created at: `1778072979`

## Task

Use the configured Bray MCP server to inspect the actual message...
```

Your agent command receives this file path as `$1` and can process it accordingly.

## Troubleshooting

### Watcher won't start

Check environment variables:
```bash
echo $NOSTR_PUBLIC_KEY
echo $NOSTR_SECRET_KEY  # Required if NIP17_PREFILTER=1 (default)
```

Check relay connectivity:
```bash
nostr-watch check
```

View logs:
```bash
nostr-watch logs 50  # Last 50 lines
# or
cat /workspace/.nostr-watch/watcher.log
```

### Dependencies missing

Verify installation:
```bash
nak --version
jq --version
tsp --version
```

### Events not detected

First, check relay connectivity:
```bash
nostr-watch check
```

Test event retrieval manually:
```bash
nak req -k 1059 -t "p=YOUR_PUBKEY_HEX" wss://relay.damus.io
```

Verify pubkey is correct hex format (64 characters, not npub):
```bash
# Convert npub to hex
nak decode npub1... | jq -r .pubkey
```

Check watcher status and queue:
```bash
nostr-watch status
```

## Platform Support

- ✅ **arm64** (Apple Silicon, Raspberry Pi, AWS Graviton)
- ✅ **amd64** (x86_64 Intel/AMD)
- ❌ **arm/v7** (not currently supported)
- ❌ **Alpine Linux** (task-spooler package name differs, needs adaptation)

## Licence

MIT

## Links

- [Nostr Protocol](https://github.com/nostr-protocol/nostr)
- [NIP-17 (Private Direct Messages)](https://github.com/nostr-protocol/nips/blob/master/17.md)
- [nak (Nostr Army Knife)](https://github.com/fiatjaf/nak)
