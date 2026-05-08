# .devcontainer-test

This folder lets you test the feature immediately from the local source in this repository:

- `../src/nostr-watch`

After GHCR publishing is enabled and a tag is released, you can switch to:

- `ghcr.io/falknerdominik/nostr-watch/nostr-watch:1`

## 1. Set required local environment variable (host side)

```bash
export NOSTR_PUBLIC_KEY=npub1_or_hex_your_public_key_here
```

## 2. Open this folder config in VS Code Dev Containers

Use "Dev Containers: Reopen in Container" and select `.devcontainer-test/devcontainer.json`.

## 3. Verify inside container

```bash
nostr-watch --version
nostr-watch status
nostr-watch logs 50
```

## Notes

- `NOSTR_PUBLIC_KEY` is passed from your host environment using `${localEnv:NOSTR_PUBLIC_KEY}`.
- The default agent command is `cat` for safe testing.
- Change `NOSTR_WATCH_AGENT_CMD` in `devcontainer.json` if you want to test your real agent.
