# Resolve the directory this script lives in, so it works regardless of where the repo is cloned
SCRIPT_DIR="${0:A:h}"

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install packages and applications
brew install \
git \
python \
node \
zsh-syntax-highlighting \
zsh-autosuggestions \
tree \
visual-studio-code \
google-chrome \
microsoft-edge \
beeper \
maccy \
bitwarden \
spotify \
notion \
claude \
dropbox \
zoom \
slack \
microsoft-teams \
vlc \
claude-code \
jetbrains-toolbox

brew install --cask \
onedrive \
iterm2

# Symlink dotfiles
ln -sf "$SCRIPT_DIR/zprofile.zsh" ~/.zprofile
ln -sf "$SCRIPT_DIR/zshrc.zsh" ~/.zshrc
ln -sf "$SCRIPT_DIR/gitconfig" ~/.gitconfig
ln -sf "$SCRIPT_DIR/gitignore_global" ~/.gitignore_global
ln -sf "$SCRIPT_DIR/.ssh" ~/.ssh

# iTerm2 setup
curl -L https://iterm2.com/shell_integration/zsh -o ~/.iterm2_shell_integration.zsh
mkdir -p ~/bin
curl -L https://iterm2.com/utilities/imgcat -o ~/bin/imgcat && chmod +x ~/bin/imgcat
curl -L https://iterm2.com/utilities/it2copy -o ~/bin/it2copy && chmod +x ~/bin/it2copy

# iTerm2 preferences
defaults write com.googlecode.iterm2 "OptionKey" -int 1
defaults write com.googlecode.iterm2 "Unlimited Scrollback" -bool true