---
name: refresh-wiki
description: This skill should be used when the user asks to refresh, update, or sync the ACC wiki snapshot, such as "refresh the wiki", "update the bundled wiki", "sync wiki content", "pull latest wiki", or "update ACC Agent wiki snapshot". Also use when the user reports that wiki content appears outdated and wants to pull the latest version from the upstream repository.
version: 0.1.0
---

# Refresh Wiki Skill

This skill updates the bundled ACC wiki snapshot with the latest content from the upstream GitHub repository.

## Overview

The ACC Agent Claude Code plugin includes a local snapshot of the LF-ACC-Wiki documentation, stored at `${CLAUDE_PLUGIN_ROOT}/references/wiki/`. This snapshot may become out of date as the upstream repository is updated. Use this skill to pull the latest wiki content and refresh your local copy.

## How It Works

Running the refresh script:
1. Clones the upstream repository (`https://github.com/6ogo/LF-ACC-Wiki`) with `--depth 1` for a shallow, lightweight clone
2. Copies all `.md` files from the repository root to your local wiki snapshot directory
3. Copies the complete `examples/` directory tree to preserve example code and scripts
4. Cleans up the temporary clone
5. Confirms the operation with a timestamp

## Usage

To refresh the wiki snapshot, run:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/skills/refresh-wiki/scripts/refresh.sh
```

Or let the agent handle it for you by requesting a refresh.

## Warning

Back up any local modifications to `references/wiki/` before running this skill. Custom edits WILL be overwritten by the upstream content.

## Verification

After the script completes, check the file timestamps in `${CLAUDE_PLUGIN_ROOT}/references/wiki/` to confirm the refresh succeeded. The modification times should reflect the current operation.

## Additional Resources

- `scripts/refresh.sh` — The bash script that performs the wiki refresh operation
