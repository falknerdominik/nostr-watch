# nostr-watch DevContainer Feature

A single-feature [DevContainer Feature](https://containers.dev/implementors/features/) repository for nostr-watch.

## Feature

Watches Nostr events and triggers an agent command when matching events arrive.

**[📖 Full Documentation](./src/nostr-watch/README.md)**

**Quick Start:**
```json
{
  "features": {
    "ghcr.io/falknerdominik/nostr-watch/nostr-watch:1": {
      "autoStart": true
    }
  }
}
```

**Highlights:**
- Multi-platform support (arm64, amd64)
- Auto-installation of dependencies (nak, jq, task-spooler)
- Clean `NOSTR_WATCH_*` environment variables
- Automatic cleanup with configurable retention
- Agent integration for custom workflows

**Use Cases:**
- Monitor Nostr DMs and trigger automated responses
- Build AI agents that respond to Nostr events
- Integrate Nostr notifications into your development workflow
- Create dispatch systems based on Nostr messages

## Easy Setup

Use this if you want the feature running with minimal setup.

### 1. Add the feature to `devcontainer.json`

```json
{
  "name": "My Project",
  "features": {
    "ghcr.io/falknerdominik/nostr-watch/nostr-watch:1": {
      "autoStart": true
    }
  }
}
```

### 2. Create a `.env` file

Do not commit this file.

```bash
# Required
NOSTR_PUBLIC_KEY=npub1_or_hex_your_public_key_here

# Optional but recommended
NOSTR_RELAYS=wss://relay.damus.io,wss://nos.lol,wss://relay.snort.social

# Optional: command to run when an event arrives
NOSTR_WATCH_AGENT_CMD=cat
```

### 3. Load `.env` into the container

If you use `docker-compose.yml`:

```yaml
services:
  devcontainer:
    env_file:
      - .env
```

If you use a plain `devcontainer.json`, pass the environment into the container using your normal runtime setup.

### 4. Rebuild the container

Rebuild or reopen the devcontainer to install the feature.

### 5. Check that it is installed

Inside the container, run:

```bash
nostr-watch --version
nostr-watch status
```

If `autoStart` is `false`, start it manually:

```bash
nostr-watch start
```

## Required and Optional Configuration

### Required environment variable

| Variable | Required | Meaning |
|----------|----------|---------|
| `NOSTR_PUBLIC_KEY` | Yes | Public key to watch for. Accepts `npub1...` or 64-character hex. |

### Common optional environment variables

| Variable | Default | Meaning |
|----------|---------|---------|
| `NOSTR_RELAYS` | `wss://relay.damus.io wss://nos.lol wss://relay.snort.social` | Relay URLs to subscribe to. Commas and spaces are both accepted. |
| `NOSTR_WATCH_AGENT_CMD` | `cat` | Command to run when an event is detected. The handoff file path is passed as `$1`. |
| `NOSTR_WATCH_KINDS` | `1059` | Event kinds to monitor. |
| `NOSTR_WATCH_ALLOWED_SENDERS` | empty | Optional comma-separated sender pubkeys to allow. |
| `NOSTR_WATCH_STATE_DIR` | `.nostr-watch` | Directory for logs, handoffs, seen markers, PID file, and runtime config. |

### Cleanup and runtime tuning

| Variable | Default | Meaning |
|----------|---------|---------|
| `NOSTR_WATCH_LOG_FILE` | `$STATE_DIR/watcher.log` | Custom log file path. |
| `NOSTR_WATCH_LOG_MAX_SIZE` | `1048576` | Max log size in bytes before the log resets. |
| `NOSTR_WATCH_START_MODE` | `daemon` | Start mode: `daemon` or `foreground`. |
| `NOSTR_WATCH_RECONNECT_SECONDS` | `5` | Base reconnect delay after an error. |
| `NOSTR_WATCH_HANDOFF_RETENTION_DAYS` | `7` | Days to retain handoff files. |
| `NOSTR_WATCH_SEEN_RETENTION_DAYS` | `7` | Days to retain seen markers. |
| `NOSTR_WATCH_CLEANUP_INTERVAL` | `3600` | Seconds between cleanup passes. |
| `NOSTR_WATCH_MAX_FILES_PER_DIR` | `1000` | Emergency cleanup threshold for handoff and seen files. |

## Common Configurations

### Minimal configuration

```json
{
  "features": {
    "ghcr.io/falknerdominik/nostr-watch/nostr-watch:1": {}
  }
}
```

```bash
NOSTR_PUBLIC_KEY=npub1_or_hex_your_public_key_here
```

### Typical agent setup

```json
{
  "features": {
    "ghcr.io/falknerdominik/nostr-watch/nostr-watch:1": {
      "autoStart": true,
      "kinds": "1059",
      "agentCmd": "/workspace/scripts/process-nostr-event.sh"
    }
  }
}
```

```bash
NOSTR_PUBLIC_KEY=npub1_or_hex_your_public_key_here
NOSTR_RELAYS=wss://relay.damus.io,wss://nos.lol
NOSTR_WATCH_AGENT_CMD=/workspace/scripts/process-nostr-event.sh
NOSTR_WATCH_STATE_DIR=/workspace/.nostr-watch
```

### Manual start configuration

Use this if you do not want the watcher to start automatically on container boot.

```json
{
  "features": {
    "ghcr.io/falknerdominik/nostr-watch/nostr-watch:1": {
      "autoStart": false
    }
  }
}
```

Then start it yourself:

```bash
nostr-watch start
```

## After Installation

Useful commands inside the container:

```bash
# Start the watcher
nostr-watch start

# Stop the watcher
nostr-watch stop

# Show status
nostr-watch status

# Show status as JSON
nostr-watch status --json

# Tail logs
nostr-watch logs

# Show the last 50 log lines
nostr-watch logs 50

# Check relay connectivity
nostr-watch check
```

## Notes

- Keep secrets out of `devcontainer.json`.
- `NOSTR_PUBLIC_KEY` may be `npub` or hex; the watcher converts `npub` automatically.
- `NOSTR_WATCH_AGENT_CMD` should be a single executable or script path. If you need extra arguments, put them in a wrapper script.
- For full feature details and examples, see [src/nostr-watch/README.md](./src/nostr-watch/README.md).

## Local Development

### Testing Features Locally

To test a feature locally before publishing:

1. **Clone this repository**
   ```bash
   git clone https://github.com/falknerdominik/nostr-watch.git
   cd nostr-watch
   ```

2. **Reference local path in devcontainer.json**
   ```json
   {
     "features": {
       "./src/nostr-watch": {
         "autoStart": true
       }
     }
   }
   ```

3. **Rebuild container**

### Running Tests

```bash
cd test/nostr-watch
chmod +x test.sh
./test.sh
```

## Publishing

### Prerequisites

- GitHub account
- GitHub Container Registry (GHCR) access

### Publishing to GHCR

1. **Enable GitHub Actions**
   - Go to repository Settings → Actions → General
   - Enable "Read and write permissions"

2. **Tag a release**
   ```bash
   git tag -a v1.0.0 -m "Release v1.0.0"
   git push origin v1.0.0
   ```

3. **GitHub Actions will automatically:**
   - Build and test features
   - Publish to `ghcr.io/falknerdominik/nostr-watch`
   - Create release notes

### Manual Publishing

```bash
# Install devcontainer CLI
npm install -g @devcontainers/cli

# Publish feature
devcontainer features publish ./src -r ghcr.io/falknerdominik/nostr-watch
```

## Feature Structure

Each feature follows this structure:

```
src/
└── feature-name/
    ├── devcontainer-feature.json   # Metadata and options
    ├── install.sh                  # Installation script
    ├── README.md                   # Documentation
    └── [additional files]          # Feature-specific files
```

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Test your changes locally
4. Submit a pull request

### Adding a New Feature

1. **Create feature directory**
   ```bash
   mkdir -p src/my-feature
   cd src/my-feature
   ```

2. **Create devcontainer-feature.json**
   ```json
   {
     "id": "my-feature",
     "version": "1.0.0",
     "name": "My Feature",
     "description": "What it does",
     "options": {},
     "installsAfter": []
   }
   ```

3. **Create install.sh**
   ```bash
   #!/usr/bin/env bash
   set -euo pipefail
   
   echo "Installing my-feature..."
   # Installation logic here
   ```

4. **Create README.md**
   Document usage, options, and examples.

5. **Add tests**
   ```bash
   mkdir -p test/my-feature
   # Create test.sh and scenarios.json
   ```

## Platform Support

| Platform | Support |
|----------|---------|
| amd64 (x86_64) | ✅ Fully supported |
| arm64 (aarch64) | ✅ Fully supported |
| arm/v7 | ⚠️  Not tested |

## Security

### Environment Variables

**⚠️ NEVER** put secrets in `devcontainer.json`. Always use:
- `.env` files (add to `.gitignore`)
- docker-compose `env_file`
- Secret management services

### Reporting Vulnerabilities

Please report security issues to: security@yourdomain.com

## Licence

MIT licence - see [LICENSE](LICENSE) for details

## Resources

- [DevContainer Features Specification](https://containers.dev/implementors/features/)
- [DevContainer Features Template](https://github.com/devcontainers/feature-template)
- [Nostr Protocol](https://github.com/nostr-protocol/nostr)
- [nak (Nostr Army Knife)](https://github.com/fiatjaf/nak)

## Support

- 📖 [Documentation](./src/nostr-watch/README.md)
- 🐛 [Issue Tracker](https://github.com/falknerdominik/nostr-watch/issues)
- 💬 [Discussions](https://github.com/falknerdominik/nostr-watch/discussions)

---

**Made with ❤️ for the DevContainer and Nostr communities**
