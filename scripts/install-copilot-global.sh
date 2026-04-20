#!/usr/bin/env bash
# Installs ACC agents to ~/.copilot/agents/ so they're available in every VS Code workspace.
# Run from repo root: bash scripts/install-copilot-global.sh

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="$HOME/.copilot/agents"

mkdir -p "$TARGET_DIR"

for src in "$REPO_ROOT/.github/agents/"*.agent.md; do
    filename="$(basename "$src")"
    sed \
        -e "s|references/wiki/|$REPO_ROOT/references/wiki/|g" \
        -e "s|skills/acc-wiki-map/references/|$REPO_ROOT/skills/acc-wiki-map/references/|g" \
        "$src" > "$TARGET_DIR/$filename"
    echo "Installed: $filename"
done

echo ""
echo "ACC agents installed to: $TARGET_DIR"
echo "Restart VS Code to pick up the changes."
