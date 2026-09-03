#!/usr/bin/env bash
#
# Archive all AI coding sessions (Claude, Codex, Gemini, Copilot, OpenCode, ...)
# into ~/Dropbox/ai-session-backups so the Dropbox app auto-syncs them.
#
# De-duplication guarantees:
#   * `continues dump` names files {source}_{id}.{md,json} and OVERWRITES in place,
#     so a given session always maps to one file -- no duplicate copies accumulate.
#   * An atomic mkdir lock prevents a scheduled run and a manual run from racing
#     on the same files (which is the only way partial/duplicate writes could happen).
#   * The script never deletes; it only refreshes existing files and adds new ones.
#
set -euo pipefail

DEST="$HOME/Dropbox/ai-session-backups"
LOG_DIR="$HOME/scripts/logs"
LOG="$LOG_DIR/ai-session-backup.log"
LOCK="/tmp/ai-session-backup.lock"   # outside Dropbox on purpose (never synced)
STALE_MIN=30                         # reclaim a lock older than this many minutes

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

mkdir -p "$DEST/markdown" "$DEST/json" "$LOG_DIR"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >>"$LOG"; }

# --- Lock guardrail: mkdir is atomic, so only one runner wins ---
if ! mkdir "$LOCK" 2>/dev/null; then
  if [ -n "$(find "$LOCK" -maxdepth 0 -mmin +"$STALE_MIN" 2>/dev/null)" ]; then
    log "Reclaiming stale lock (> ${STALE_MIN}m old)"
    rmdir "$LOCK" 2>/dev/null || true
    mkdir "$LOCK" 2>/dev/null || { log "Lock still busy; exiting"; exit 0; }
  else
    log "Another backup is in progress; exiting"
    exit 0
  fi
fi
trap 'rmdir "$LOCK" 2>/dev/null || true' EXIT

CONT="$(command -v continues || true)"
[ -n "$CONT" ] || CONT="npx -y continues"

log "Backup started (binary: $CONT)"
"$CONT" dump all "$DEST/markdown" >>"$LOG" 2>&1
"$CONT" dump all "$DEST/json" --json --preset full >>"$LOG" 2>&1

md=$(find "$DEST/markdown" -maxdepth 1 -type f -name '*.md' | wc -l | tr -d ' ')
js=$(find "$DEST/json" -maxdepth 1 -type f -name '*.json' | wc -l | tr -d ' ')
log "Backup complete: markdown=$md json=$js"
