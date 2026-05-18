#!/usr/bin/env bash
# Install Claude Code config: CLAUDE.md and statusline get overwritten;
# settings.json is key-merge-overwritten; shared-skills hooks/skills wired up.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
CLAUDE_DIR="$HOME/.claude"
SHARED_SKILLS_REPO="${SHARED_SKILLS_REPO:-https://github.com/DavidTeju/shared-skills.git}"

mkdir -p "$CLAUDE_DIR"

cp "$SCRIPT_DIR/CLAUDE.md"             "$CLAUDE_DIR/CLAUDE.md"
cp "$SCRIPT_DIR/statusline-command.sh" "$CLAUDE_DIR/statusline-command.sh"
chmod +x "$CLAUDE_DIR/statusline-command.sh"

SHARED_SKILLS_DIR=""
for candidate in "$HOME/projects/shared-skills" "$HOME/shared-skills"; do
    if [ -d "$candidate/.git" ]; then
        SHARED_SKILLS_DIR="$candidate"
        break
    fi
done

if [ -z "$SHARED_SKILLS_DIR" ]; then
    SHARED_SKILLS_DIR="$HOME/projects/shared-skills"
    echo "==> cloning shared-skills → $SHARED_SKILLS_DIR"
    mkdir -p "$(dirname "$SHARED_SKILLS_DIR")"
    git clone "$SHARED_SKILLS_REPO" "$SHARED_SKILLS_DIR"
fi

if [ -x "$SHARED_SKILLS_DIR/setup.sh" ]; then
    echo "==> running shared-skills setup ($SHARED_SKILLS_DIR)"
    bash "$SHARED_SKILLS_DIR/setup.sh" local
fi

# Merge AFTER shared-skills setup so our specific matcher patterns
# (e.g. "Edit|Write|Bash|...") win over setup.sh's default `""` matcher.
SETTINGS="$CLAUDE_DIR/settings.json"
OVERRIDES="$SCRIPT_DIR/settings.json"

if ! command -v jq >/dev/null 2>&1; then
    echo "==> jq required for settings merge; install it (apt-get install -y jq)" >&2
    exit 1
fi

if [ -f "$SETTINGS" ]; then
    cp "$SETTINGS" "$SETTINGS.bak.$(date +%s)"
    jq -s '.[0] * .[1]' "$SETTINGS" "$OVERRIDES" > "$SETTINGS.tmp"
    mv "$SETTINGS.tmp" "$SETTINGS"
    echo "==> merged $OVERRIDES into $SETTINGS (backup saved)"
else
    cp "$OVERRIDES" "$SETTINGS"
    echo "==> wrote fresh $SETTINGS"
fi
