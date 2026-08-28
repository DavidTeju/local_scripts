#!/usr/bin/env bash
# macOS installer. Invoked by ../fresh_install.sh on Darwin.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Homebrew
if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"

# Oh My Zsh (non-interactive — don't overwrite zshrc, don't chsh, don't launch zsh)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

TAPS=(
    beeper/tap hostinger/tap steipete/tap supabase/tap
)

FORMULAE=(
    git python node tree jq
    zsh-syntax-highlighting zsh-autosuggestions
    bitwarden-cli bun cowsay dnscrypt-proxy dnsmasq duti exiftool
    gh go googleworkspace-cli hostinger/tap/hostinger
    steipete/tap/gogcli minikube nmap ollama openai-whisper
    poppler pymupdf pyright rclone so spotify_player
    supabase/tap/supabase tldr todoist-cli
    typescript-language-server uv whisper-cpp x-cli
)

CASKS=(
    visual-studio-code google-chrome microsoft-edge
    alt-tab antigravity-cli beeper beeper-desktop-cli bitwarden
    claude claude-code@latest codex cold-turkey-blocker copilot-cli
    cursor discord dropbox gcloud-cli github-copilot-app iterm2
    jetbrains-toolbox libreoffice maccy microsoft-office mitmproxy
    notion notion-calendar obsidian opal-app orbstack photosweeper-x
    protonvpn qbittorrent slack spokenly spotify
    tailscale-app telegram todoist-app vlc windows-app zoom
)

for tap in "${TAPS[@]}"; do brew tap "$tap"; done
brew install "${FORMULAE[@]}"
brew install --cask "${CASKS[@]}"

# Global CLIs that don't come from Homebrew.
NPM_GLOBALS=(
    @playwright/cli playwright betahi-copilot-bridge continues
)
if command -v npm >/dev/null 2>&1; then
    npm install -g "${NPM_GLOBALS[@]}"
fi

if command -v bun >/dev/null 2>&1; then
    bun install -g @stephendolan/ynab-cli
fi

if command -v uv >/dev/null 2>&1; then
    uv tool install it2
fi

# Symlink dotfiles. Shared files live at the repo root or under lib/.
ln -sfn "$SCRIPT_DIR/zprofile.zsh"     "$HOME/.zprofile"
ln -sfn "$REPO_DIR/lib/zshrc.zsh"      "$HOME/.zshrc"
ln -sfn "$REPO_DIR/gitconfig"          "$HOME/.gitconfig"
ln -sfn "$REPO_DIR/gitignore_global"   "$HOME/.gitignore_global"

# ~/.ssh is usually a real dir with keys — never symlink the whole dir,
# only the config file.
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
ln -sfn "$SCRIPT_DIR/.ssh/config" "$HOME/.ssh/config"
chmod 600 "$SCRIPT_DIR/.ssh/config" 2>/dev/null || true

# Symlink app configs.
mkdir -p "$HOME/.config/gh" "$HOME/.config/todoist"
ln -sfn "$REPO_DIR/gh/config.yml" "$HOME/.config/gh/config.yml"
ln -sfn "$REPO_DIR/gh/hosts.yml" "$HOME/.config/gh/hosts.yml"

mkdir -p "$HOME/Library/Application Support/io.Sam-Tay.so"
[ -f "$REPO_DIR/so_config.yml" ] && ln -sfn "$REPO_DIR/so_config.yml" "$HOME/Library/Application Support/io.Sam-Tay.so/config.yml"
[ -f "$REPO_DIR/xrc" ] && ln -sfn "$REPO_DIR/xrc" "$HOME/.xrc"
[ -f "$REPO_DIR/todoist_config.json" ] && ln -sfn "$REPO_DIR/todoist_config.json" "$HOME/.config/todoist/config.json"

# VS Code settings and extensions.
mkdir -p "$HOME/Library/Application Support/Code/User"
ln -sfn "$REPO_DIR/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
ln -sfn "$REPO_DIR/vscode/keybindings.json" "$HOME/Library/Application Support/Code/User/keybindings.json"
if command -v code >/dev/null 2>&1; then
    xargs -n1 code --install-extension < "$REPO_DIR/vscode/extensions.txt"
else
    echo "==> VS Code CLI not found; skipping extension install"
fi

# Claude Code config (CLAUDE.md + statusline + settings.json merge)
if [ -x "$REPO_DIR/ai/install.sh" ]; then
    bash "$REPO_DIR/ai/install.sh"
fi

# iTerm2 setup
curl -L https://iterm2.com/shell_integration/zsh -o ~/.iterm2_shell_integration.zsh
mkdir -p ~/bin
# macOS markdown opener used by Open With / app bundle wrappers.
ln -sfn "$REPO_DIR/obsidian-opener.sh" "$HOME/bin/obsidian-opener"
# Captive-portal DNS escape hatch (needed because dnsmasq runs with no-resolv).
ln -sfn "$REPO_DIR/portal-login" "$HOME/bin/portal-login"

curl -L https://iterm2.com/utilities/imgcat -o ~/bin/imgcat && chmod +x ~/bin/imgcat
curl -L https://iterm2.com/utilities/it2copy -o ~/bin/it2copy && chmod +x ~/bin/it2copy

# iTerm2 preferences (restore from exported plist)
plutil -convert binary1 -o "$HOME/Library/Preferences/com.googlecode.iterm2.plist" "$REPO_DIR/iterm2.plist"
