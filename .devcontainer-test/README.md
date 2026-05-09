# .devcontainer-test

Basic handoff for another agent to get `nostr-watch` running in this repository.

## Devcontainer environment loading

The devcontainer must load environment variables from the workspace root `.env` file.
This config does that via `runArgs` with `--env-file` and `${localWorkspaceFolder}/.env`.

This avoids the common failure where Dev Containers searches `/workspace/.env` while your file is elsewhere.

## Workspace root `.env` values

Required by `nostr-watch`:

```bash
NOSTR_PUBLIC_KEY=npub1_or_hex_your_public_key_here
```

Recommended for broader local Nostr tooling:

```bash
NOSTR_SECRET_KEY=nsec1...
NOSTR_RELAYS=wss://relay.damus.io wss://nos.lol wss://relay.snort.social
```

## Feature install/config in `devcontainer.json`

This `.devcontainer-test/devcontainer.json` uses:

- `image`: `mcr.microsoft.com/devcontainers/base:debian`
- `feature`: `ghcr.io/falknerdominik/nostr-watch/nostr-watch:1`
- `containerEnv`: `NOSTR_WATCH_AGENT_CMD=cat` (safe testing default)
- `postCreateCommand`: `nostr-watch --version && nostr-watch status || true`

## Rebuild/reopen container

After changing `.env` or devcontainer configuration, run:

- Dev Containers: Rebuild and Reopen in Container

## Verify inside container

Run:

```bash
nostr-watch --version
nostr-watch status
nostr-watch logs 50
```

## Notes

- The `UndefinedVar` warnings during image build can be non-fatal for this feature and setup.
- If you intentionally want the env file under `.devcontainer/.env`, update `runArgs` in `.devcontainer-test/devcontainer.json` from `${localWorkspaceFolder}/.env` to `${localWorkspaceFolder}/.devcontainer/.env`.
