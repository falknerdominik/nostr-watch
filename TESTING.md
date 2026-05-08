# Test DevContainer for nostr-watch Feature

This is a minimal test environment for the nostr-watch feature.

## Setup

1. **Create .env file** (don't commit):
   ```bash
   cp .env.example .env
   # Edit .env and add your NOSTR_PUBLIC_KEY
   ```

2. **Rebuild container**:
   - VS Code: `Cmd/Ctrl+Shift+P` → "Dev Containers: Rebuild Container"
   - CLI: `devcontainer up --workspace-folder .`

3. **Verify installation**:
   ```bash
   nostr-watch --version
   which nostr-watch
   nak --version
   ```

4. **Check dependencies**:
   ```bash
   cd /workspace/devcontainer-features/test/nostr-watch
   ./test.sh
   ```

5. **Start the watcher**:
   ```bash
   nostr-watch start
   ```

6. **Check status**:
   ```bash
   nostr-watch status
   cat /workspace/.nostr-watch/watcher.log
   ```

## Expected Results

- ✓ `nostr-watch` command available in PATH
- ✓ All dependencies installed (nak, jq, tsp, git, curl)
- ✓ Watcher starts without errors
- ✓ Log shows connection to relays
- ✓ State directory created at `/workspace/.nostr-watch/`

## Troubleshooting

**If installation fails:**
```bash
# Check installation logs
docker logs <container-id>

# Manual install test
cd src/nostr-watch
sudo bash install.sh
```

**If watcher fails to start:**
```bash
# Check environment
echo $NOSTR_PUBLIC_KEY
echo $NOSTR_RELAYS

# Check logs
tail -f /workspace/.nostr-watch/watcher.log
```

**Test architecture detection:**
```bash
uname -m
echo $TARGETARCH
```
