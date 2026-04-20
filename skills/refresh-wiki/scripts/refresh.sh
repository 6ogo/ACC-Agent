#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# scripts -> refresh-wiki -> skills -> plugin root
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-"$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"}"

WIKI_SNAPSHOT_DIR="${PLUGIN_ROOT}/references/wiki"

if [ ! -d "$WIKI_SNAPSHOT_DIR" ]; then
  echo "Error: Wiki snapshot directory not found: $WIKI_SNAPSHOT_DIR"
  echo "Is CLAUDE_PLUGIN_ROOT set correctly?"
  exit 1
fi

UPSTREAM_REPO="https://github.com/6ogo/LF-ACC-Wiki"

# Create temp directory with cleanup trap
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Refreshing ACC wiki snapshot..."
echo "Plugin root: $PLUGIN_ROOT"
echo "Wiki snapshot directory: $WIKI_SNAPSHOT_DIR"
echo ""

echo "Step 1: Cloning upstream repository from $UPSTREAM_REPO..."
git clone --depth 1 "$UPSTREAM_REPO" "$TMP_DIR"
echo "  Clone complete."
echo ""

echo "Step 2: Copying markdown files..."
find "$TMP_DIR" -maxdepth 1 -type f -name "*.md" -exec cp {} "$WIKI_SNAPSHOT_DIR/" \;
echo "  Markdown files copied to $WIKI_SNAPSHOT_DIR/"
echo ""

echo "Step 3: Copying examples directory..."
if [ -d "$TMP_DIR/examples" ]; then
  rm -rf "$WIKI_SNAPSHOT_DIR/examples"
  cp -r "$TMP_DIR/examples" "$WIKI_SNAPSHOT_DIR/"
  echo "  Examples directory copied to $WIKI_SNAPSHOT_DIR/examples/"
else
  echo "  Warning: No examples directory found in upstream repo."
fi
echo ""

echo "Step 4: Cleaning up temporary files..."
# Cleanup handled by trap, but explicit message for clarity
echo "  Temporary clone directory removed."
echo ""

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
echo "Wiki refresh complete at $TIMESTAMP"
echo "Your wiki snapshot has been updated with the latest content."
