# Resolve the directory this script lives in, so it works regardless of where the repo is cloned
SCRIPT_DIR="${0:A:h}"

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install Oh My Zsh (skip if already installed)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install packages and applications
brew install \
git \
python \
node \
zsh-syntax-highlighting \
zsh-autosuggestions \
tree \
cowsay \
gemini-cli \
gh \
go \
googleworkspace-cli \
steipete/tap/gogcli \
nmap \
ollama \
openai-whisper \
poppler \
pymupdf \
so \
supabase/tap/supabase \
tldr \
todoist-cli \
typescript-language-server \
uv \
whisper-cpp \
x-cli

brew install --cask \
alt-tab \
beeper \
beeper-desktop-cli \
bitwarden \
claude \
claude-code \
copilot-cli \
dropbox \
gcloud-cli \
google-chrome \
iterm2 \
jetbrains-toolbox \
maccy \
microsoft-edge \
microsoft-office \
notion \
notion-calendar \
opal-app \
orbstack \
slack \
spotify \
superwhisper \
tailscale-app \
telegram \
todoist-app \
visual-studio-code \
vlc \
zoom

# Symlink dotfiles
ln -sf "$SCRIPT_DIR/zprofile.zsh" ~/.zprofile
ln -sf "$SCRIPT_DIR/zshrc.zsh" ~/.zshrc
ln -sf "$SCRIPT_DIR/gitconfig" ~/.gitconfig
ln -sf "$SCRIPT_DIR/gitignore_global" ~/.gitignore_global
ln -sf "$SCRIPT_DIR/.ssh" ~/.ssh

# Symlink app configs
mkdir -p ~/.config/gh ~/.config/todoist
ln -sf "$SCRIPT_DIR/gh/config.yml" ~/.config/gh/config.yml
ln -sf "$SCRIPT_DIR/gh/hosts.yml" ~/.config/gh/hosts.yml
mkdir -p ~/Library/Application\ Support/io.Sam-Tay.so
ln -sf "$SCRIPT_DIR/so_config.yml" ~/Library/Application\ Support/io.Sam-Tay.so/config.yml
ln -sf "$SCRIPT_DIR/xrc" ~/.xrc
ln -sf "$SCRIPT_DIR/todoist_config.json" ~/.config/todoist/config.json

# VS Code settings
mkdir -p ~/Library/Application\ Support/Code/User
ln -sf "$SCRIPT_DIR/vscode/settings.json" ~/Library/Application\ Support/Code/User/settings.json
ln -sf "$SCRIPT_DIR/vscode/keybindings.json" ~/Library/Application\ Support/Code/User/keybindings.json

# VS Code extensions
xargs -n1 code --install-extension < "$SCRIPT_DIR/vscode/extensions.txt"

# iTerm2 setup
curl -L https://iterm2.com/shell_integration/zsh -o ~/.iterm2_shell_integration.zsh
mkdir -p ~/bin
curl -L https://iterm2.com/utilities/imgcat -o ~/bin/imgcat && chmod +x ~/bin/imgcat
curl -L https://iterm2.com/utilities/it2copy -o ~/bin/it2copy && chmod +x ~/bin/it2copy

# iTerm2 preferences (restore from exported plist)
plutil -convert binary1 -o ~/Library/Preferences/com.googlecode.iterm2.plist "$SCRIPT_DIR/iterm2.plist"