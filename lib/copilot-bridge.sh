# copilot-bridge — use your GitHub Copilot subscription as a local
# OpenAI/Anthropic-compatible API for BOTH Codex CLI and Claude Code.
#
# Backed by betahi-copilot-bridge (pinned). Talks DIRECTLY to GitHub
# (api.githubcopilot.com) — no third-party host. Runs as a launchd service
# bound to 127.0.0.1:4142 (KeepAlive), so plain `codex` and `claude` — plus
# Claude Code hooks/teammates and any GUI launch — all route through Copilot.
#
# Routing is already wired globally:
#   Codex  -> ~/.codex/config.toml   (model_provider = "bridge", :4142)
#   Claude -> ~/.claude/settings.json (env ANTHROPIC_BASE_URL = :4142)
# So you normally just run `codex` / `claude` directly. The helpers below are
# for controlling the service and quick health checks.
#
# Commands:
#   copilot-bridge-status     service running + port + live health check
#   copilot-bridge-start      load/kickstart the launchd service
#   copilot-bridge-stop       stop the launchd service
#   copilot-bridge-restart    restart the service
#   copilot-bridge-logs       tail the server log
#   copilot-bridge-login      (re)authenticate with GitHub (device flow)
#   copilot-bridge-usage      print the Copilot quota usage snapshot
#   claude-copilot [args...]  ensure bridge is up, then run claude
#   codex-copilot  [args...]  ensure bridge is up, then run codex
#
# NOTE: Cursor is unsupported (it rejects localhost base URLs).
# NOTE: gpt-5.x-codex work natively via the Responses API through the bridge.

COPILOT_BRIDGE_PORT="${COPILOT_BRIDGE_PORT:-4142}"
COPILOT_BRIDGE_LABEL="com.femi.copilot-bridge"
COPILOT_BRIDGE_PLIST="${HOME}/Library/LaunchAgents/${COPILOT_BRIDGE_LABEL}.plist"
COPILOT_BRIDGE_LOG="${HOME}/.local/share/copilot-bridge/server.log"

_copilot_bridge_listening() {
    lsof -nP -iTCP:"${COPILOT_BRIDGE_PORT}" -sTCP:LISTEN >/dev/null 2>&1
}

_copilot_bridge_healthy() {
    curl -fsS -m 4 "http://127.0.0.1:${COPILOT_BRIDGE_PORT}/v1/models" >/dev/null 2>&1
}

copilot-bridge-status() {
    if launchctl list 2>/dev/null | grep -q "${COPILOT_BRIDGE_LABEL}"; then
        echo "service: loaded (${COPILOT_BRIDGE_LABEL})"
    else
        echo "service: NOT loaded"
    fi
    if _copilot_bridge_listening; then
        echo "port ${COPILOT_BRIDGE_PORT}: listening (pid $(lsof -nP -iTCP:"${COPILOT_BRIDGE_PORT}" -sTCP:LISTEN -t 2>/dev/null | head -1))"
    else
        echo "port ${COPILOT_BRIDGE_PORT}: not listening"
    fi
    if _copilot_bridge_healthy; then
        echo "health: OK (http://127.0.0.1:${COPILOT_BRIDGE_PORT})"
    else
        echo "health: FAIL — run 'copilot-bridge-restart' or check 'copilot-bridge-logs'"
        return 1
    fi
}

copilot-bridge-start() {
    launchctl load -w "${COPILOT_BRIDGE_PLIST}" 2>/dev/null
    launchctl kickstart -k "gui/$(id -u)/${COPILOT_BRIDGE_LABEL}" 2>/dev/null
    local i=0
    while [ $i -lt 15 ]; do
        _copilot_bridge_healthy && { echo "copilot-bridge up on http://127.0.0.1:${COPILOT_BRIDGE_PORT}"; return 0; }
        sleep 1; i=$((i + 1))
    done
    echo "copilot-bridge failed health check; see ${COPILOT_BRIDGE_LOG}" >&2
    return 1
}

copilot-bridge-stop() {
    launchctl unload "${COPILOT_BRIDGE_PLIST}" 2>/dev/null \
        && echo "copilot-bridge stopped" \
        || echo "copilot-bridge not loaded"
}

copilot-bridge-restart() {
    launchctl kickstart -k "gui/$(id -u)/${COPILOT_BRIDGE_LABEL}" 2>/dev/null || copilot-bridge-start
    local i=0
    while [ $i -lt 15 ]; do
        _copilot_bridge_healthy && { echo "copilot-bridge restarted"; return 0; }
        sleep 1; i=$((i + 1))
    done
    echo "copilot-bridge restart failed health check; see ${COPILOT_BRIDGE_LOG}" >&2
    return 1
}

copilot-bridge-logs() {
    tail -n "${1:-40}" -f "${COPILOT_BRIDGE_LOG}"
}

copilot-bridge-login() {
    # Re-run GitHub device-flow auth (token stored at ~/.local/share/copilot-bridge/github_token)
    betahi-copilot-bridge auth
}

copilot-bridge-usage() {
    curl -fsS -m 8 "http://127.0.0.1:${COPILOT_BRIDGE_PORT}/usage" 2>/dev/null \
        || echo "usage unavailable — is the bridge up? (copilot-bridge-status)"
}

# Preflight: warn (don't fail) if the bridge is down before launching a client.
_copilot_bridge_preflight() {
    if ! _copilot_bridge_healthy; then
        echo "⚠ copilot-bridge not responding on :${COPILOT_BRIDGE_PORT}; attempting start..." >&2
        copilot-bridge-start || echo "⚠ bridge still down — client may fail. Check 'copilot-bridge-logs'." >&2
    fi
}

# Routing is already global via ~/.claude/settings.json and ~/.codex/config.toml,
# so these wrappers just ensure the service is healthy first.
claude-copilot() { _copilot_bridge_preflight; claude "$@"; }
codex-copilot()  { _copilot_bridge_preflight; codex "$@"; }
