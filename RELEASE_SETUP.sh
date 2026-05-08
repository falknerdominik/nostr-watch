#!/bin/bash
set -euo pipefail

REPO_OWNER="falknerdominik"
REPO_NAME="nostr-watch"

echo "Preparing release setup for ${REPO_OWNER}/${REPO_NAME}..."

echo "[1/2] Validating feature metadata..."
if command -v jq >/dev/null 2>&1; then
  jq empty src/nostr-watch/devcontainer-feature.json
  echo "     [OK] devcontainer-feature.json is valid"
else
  echo "     [WARN] jq not found, skipping JSON validation"
fi

echo "[2/2] Validating workflow file..."
if [ -f .github/workflows/mirror-and-test.yml ]; then
  echo "     [OK] Workflow file present"
else
  echo "     [ERROR] Missing .github/workflows/mirror-and-test.yml"
  exit 1
fi

echo ""
echo "Release setup complete for ${REPO_OWNER}/${REPO_NAME}."
echo ""
echo "Next steps:"
echo "  1. Create GitHub repo: https://github.com/new"
echo "  2. Name: nostr-watch"
echo "  3. Push code from this directory: git push -u origin main"
echo "  4. Create Codeberg repo: https://codeberg.org/new"
echo "  5. Add GitHub secret: CODEBERG_TOKEN"
echo "  6. Trigger CI: git commit --allow-empty -m 'test: trigger CI' && git push"
echo "  7. Tag release: git tag -a v1.1.0 -m 'Release v1.1.0' && git push origin v1.1.0"
echo "  8. Create GitHub Release at: https://github.com/${REPO_OWNER}/${REPO_NAME}/releases"
