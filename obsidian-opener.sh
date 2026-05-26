#!/bin/bash
# Routes a markdown file to Obsidian (if inside a registered vault) or to a
# fallback editor (TextEdit) otherwise. Works around the Electron limitation
# where Obsidian.app discards file args from macOS Open With / double-click.

set -euo pipefail

FILE="${1:-}"
[ -z "$FILE" ] && exit 0

# Resolve to absolute path
FILE="$(cd "$(dirname "$FILE")" && pwd)/$(basename "$FILE")"

OBSIDIAN_JSON="$HOME/Library/Application Support/obsidian/obsidian.json"

if [ -f "$OBSIDIAN_JSON" ]; then
    IN_VAULT=$(python3 -c "
import json, sys
path = sys.argv[1]
try:
    vaults = json.load(open(sys.argv[2]))['vaults'].values()
    print('yes' if any(path.startswith(v['path']) for v in vaults) else 'no')
except Exception:
    print('no')
" "$FILE" "$OBSIDIAN_JSON")
else
    IN_VAULT="no"
fi

if [ "$IN_VAULT" = "yes" ]; then
    URL="obsidian://open?path=$(python3 -c 'import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))' "$FILE")"
    open "$URL"
else
    open -a "TextEdit" "$FILE"
fi
