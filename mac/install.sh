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

FORMULAE=(
    git python node tree jq
    zsh-syntax-highlighting zsh-autosuggestions
)

CASKS=(
    visual-studio-code google-chrome microsoft-edge
    beeper maccy bitwarden spotify notion claude
    dropbox zoom slack microsoft-teams vlc
    claude-code jetbrains-toolbox
    onedrive iterm2
)

brew install "${FORMULAE[@]}"
brew install --cask "${CASKS[@]}"

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

# Claude Code config (CLAUDE.md + statusline + settings.json merge)
if [ -x "$REPO_DIR/ai/install.sh" ]; then
    bash "$REPO_DIR/ai/install.sh"
fi

# iTerm2 setup
curl -L https://iterm2.com/shell_integration/zsh -o ~/.iterm2_shell_integration.zsh
mkdir -p ~/bin
curl -L https://iterm2.com/utilities/imgcat -o ~/bin/imgcat && chmod +x ~/bin/imgcat
curl -L https://iterm2.com/utilities/it2copy -o ~/bin/it2copy && chmod +x ~/bin/it2copy

# iTerm2 preferences
defaults write com.googlecode.iterm2 "OptionKey" -int 1
defaults write com.googlecode.iterm2 "Unlimited Scrollback" -bool true
