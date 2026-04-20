#!/usr/bin/env bash
# bootstrap-wiki.sh
# Run once during initial setup to clone the LF-ACC-Wiki and copy content
# into this plugin's references/wiki/ directory.
#
# Environment variables:
#   CLAUDE_PLUGIN_ROOT  — root of this plugin (defaults to parent of scripts/)
#   WIKI_SOURCE_URL     — upstream wiki repo (defaults to https://github.com/6ogo/LF-ACC-Wiki)

set -euo pipefail

WIKI_SOURCE_URL="${WIKI_SOURCE_URL:-https://github.com/6ogo/LF-ACC-Wiki}"

# Resolve plugin root: use CLAUDE_PLUGIN_ROOT if set, else parent of this script's dir
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-"$(dirname "$SCRIPT_DIR")"}"

DEST="${PLUGIN_ROOT}/references/wiki"

# Create a temp dir and register a cleanup trap
TMP_DIR=$(mktemp -d)
trap 'echo "Cleaning up temporary clone..."; rm -rf "$TMP_DIR"' EXIT

echo "Bootstrap ACC Wiki"
echo "  Source URL  : ${WIKI_SOURCE_URL}"
echo "  Plugin root : ${PLUGIN_ROOT}"
echo "  Destination : ${DEST}"
echo ""

# Step 1: Clone upstream repo (shallow)
echo "Step 1: Cloning ${WIKI_SOURCE_URL} (depth 1)..."
git clone --depth 1 "$WIKI_SOURCE_URL" "$TMP_DIR"
echo "  Clone complete."
echo ""

# Step 2: Ensure destination exists
echo "Step 2: Ensuring destination directory exists..."
mkdir -p "${DEST}/examples"
echo "  Directory ready: ${DEST}"
echo ""

# Step 3: Copy root markdown files
echo "Step 3: Copying root *.md files..."
find "$TMP_DIR" -maxdepth 1 -type f -name "*.md" -exec cp {} "${DEST}/" \;
echo "  Markdown files copied to ${DEST}/"
echo ""

# Step 4: Copy examples directory
echo "Step 4: Copying examples/ directory..."
if [ -d "$TMP_DIR/examples" ]; then
  rm -rf "${DEST}/examples"
  cp -r "$TMP_DIR/examples" "${DEST}/"
  echo "  examples/ copied to ${DEST}/examples/"
else
  echo "  Warning: No examples/ directory found in upstream repo (skipping)."
fi
echo ""

echo "Done. Wiki content bootstrapped into ${DEST}"
