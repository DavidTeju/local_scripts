#!/usr/bin/env bash
# Linux (Debian/Ubuntu) installer. Invoked by ../fresh_install.sh on Linux.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
SUDO=""
if [ "$(id -u)" -ne 0 ]; then SUDO="sudo"; fi

# Headless vs desktop — GUI apps only install when there's a display.
HAS_GUI=0
if [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ] || [ -n "${XDG_CURRENT_DESKTOP:-}" ]; then
    HAS_GUI=1
fi

APT_BASE=(
    git curl wget ca-certificates gnupg lsb-release
    software-properties-common apt-transport-https build-essential
    zsh tree cowsay fortune-mod
    zsh-syntax-highlighting zsh-autosuggestions
    python3 python3-pip python3-venv
    fzf ripgrep bat jq unzip htop tealdeer unattended-upgrades
)

echo "==> apt update / base CLI packages"
$SUDO apt-get update
$SUDO apt-get install -y "${APT_BASE[@]}"

# Register all third-party apt repos up front, then a single update+install at the end —
# avoids running apt-get update once per repo.
THIRD_PARTY_PKGS=()

if ! command -v gh >/dev/null 2>&1; then
    echo "==> registering GitHub CLI repo"
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | $SUDO dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    $SUDO chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        | $SUDO tee /etc/apt/sources.list.d/github-cli.list >/dev/null
    THIRD_PARTY_PKGS+=(gh)
fi

if [ "$HAS_GUI" -eq 1 ]; then
    # VS Code and Edge share the same Microsoft signing key — fetch once.
    MS_KEYRING=/usr/share/keyrings/packages.microsoft.gpg
    need_ms_key=0
    { ! command -v code >/dev/null 2>&1; } && need_ms_key=1
    { ! command -v microsoft-edge >/dev/null 2>&1; } && need_ms_key=1
    if [ "$need_ms_key" -eq 1 ] && [ ! -f "$MS_KEYRING" ]; then
        curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
            | gpg --dearmor \
            | $SUDO dd of="$MS_KEYRING"
    fi

    if ! command -v code >/dev/null 2>&1; then
        echo "deb [arch=amd64,arm64,armhf signed-by=$MS_KEYRING] https://packages.microsoft.com/repos/code stable main" \
            | $SUDO tee /etc/apt/sources.list.d/vscode.list >/dev/null
        THIRD_PARTY_PKGS+=(code)
    fi
    if ! command -v microsoft-edge >/dev/null 2>&1; then
        echo "deb [arch=amd64 signed-by=$MS_KEYRING] https://packages.microsoft.com/repos/edge stable main" \
            | $SUDO tee /etc/apt/sources.list.d/microsoft-edge.list >/dev/null
        THIRD_PARTY_PKGS+=(microsoft-edge-stable)
    fi
fi

if [ "${#THIRD_PARTY_PKGS[@]}" -gt 0 ]; then
    $SUDO apt-get update
    $SUDO apt-get install -y "${THIRD_PARTY_PKGS[@]}"
fi

# Unattended-upgrades: enable the security pocket (default 50unattended-upgrades
# already turns it on; this enables the daily timer that actually pulls them).
$SUDO tee /etc/apt/apt.conf.d/20auto-upgrades >/dev/null <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF

# Prime the tealdeer cache so `tldr <cmd>` works immediately.
tldr --update >/dev/null 2>&1 &

# Node.js (NodeSource LTS — Ubuntu's apt node is usually stale)
if ! command -v node >/dev/null 2>&1; then
    echo "==> installing Node.js LTS via NodeSource"
    curl -fsSL https://deb.nodesource.com/setup_lts.x | $SUDO -E bash -
    $SUDO apt-get install -y nodejs
fi

# Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "==> installing Oh My Zsh"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Claude Code (npm global, cross-platform)
if ! command -v claude >/dev/null 2>&1; then
    echo "==> installing Claude Code"
    $SUDO npm install -g @anthropic-ai/claude-code
fi

if [ "$HAS_GUI" -eq 1 ]; then
    echo "==> desktop session detected — installing GUI apps"

    # Google Chrome (direct .deb — no Google apt repo)
    if ! command -v google-chrome >/dev/null 2>&1; then
        wget -q -O /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        $SUDO apt-get install -y /tmp/chrome.deb
        rm -f /tmp/chrome.deb
    fi

    # Flatpak + Flathub
    if ! command -v flatpak >/dev/null 2>&1; then
        $SUDO apt-get install -y flatpak
    fi
    flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo

    FLATPAK_APPS=(
        com.spotify.Client
        com.slack.Slack
        us.zoom.Zoom
        com.bitwarden.desktop
        org.videolan.VLC
        com.discordapp.Discord
    )
    for app in "${FLATPAK_APPS[@]}"; do
        flatpak install -y --user --noninteractive flathub "$app" \
            || echo "==> flatpak skipped: $app"
    done

    # CopyQ (clipboard, closest analogue to Maccy) + OneDrive CLI sync client (abraunegg/onedrive)
    $SUDO apt-get install -y copyq onedrive \
        || echo "==> apt skipped: copyq and/or onedrive unavailable on this release"

    # JetBrains Toolbox — no apt repo
    if [ ! -x "$HOME/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox" ]; then
        echo "==> JetBrains Toolbox: download manually from https://www.jetbrains.com/toolbox-app/"
    fi
else
    echo "==> no desktop session — skipping GUI apps"
fi

# Symlink dotfiles. Shared files live at the repo root or under lib/.
echo "==> symlinking dotfiles"
ln -sfn "$SCRIPT_DIR/zprofile.zsh"     "$HOME/.zprofile"
ln -sfn "$REPO_DIR/lib/zshrc.zsh"      "$HOME/.zshrc"
ln -sfn "$SCRIPT_DIR/bashrc.sh"        "$HOME/.bashrc.local"
ln -sfn "$REPO_DIR/gitconfig"          "$HOME/.gitconfig"
ln -sfn "$REPO_DIR/gitignore_global"   "$HOME/.gitignore_global"

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
ln -sfn "$SCRIPT_DIR/.ssh/config" "$HOME/.ssh/config"
chmod 600 "$SCRIPT_DIR/.ssh/config" 2>/dev/null || true

# Wire bashrc.sh into ~/.bashrc (idempotent)
if [ -f "$HOME/.bashrc" ] && ! grep -q "bashrc.local" "$HOME/.bashrc"; then
    {
        echo ""
        echo "# Sourced from local_scripts/linux"
        echo "[ -f \"\$HOME/.bashrc.local\" ] && . \"\$HOME/.bashrc.local\""
    } >> "$HOME/.bashrc"
fi

# Claude Code config (CLAUDE.md + statusline + settings.json merge)
if [ -x "$REPO_DIR/ai/install.sh" ]; then
    bash "$REPO_DIR/ai/install.sh"
fi

# Make zsh the login shell. For root no password is needed; for non-root users
# we just print the hint (chsh would prompt).
ZSH_BIN="$(command -v zsh || true)"
if [ -n "$ZSH_BIN" ]; then
    current_shell="$(getent passwd "$USER" | cut -d: -f7)"
    if [ "$current_shell" != "$ZSH_BIN" ]; then
        if [ "$(id -u)" -eq 0 ]; then
            chsh -s "$ZSH_BIN" || echo "==> chsh failed; run manually: chsh -s $ZSH_BIN"
        else
            echo "==> To make zsh your login shell: chsh -s $ZSH_BIN"
        fi
    fi
fi

echo "==> done. Open a new shell (or 'exec zsh') to load the config."
