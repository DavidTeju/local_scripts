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
bitwarden \
claude \
dropbox \
zoom \
slack \
microsoft-teams \
vlc \
claude-code

brew install --cask \
onedrive

# Symlink dotfiles
ln -sf ~/scripts/zprofile.zsh ~/.zprofile
ln -sf ~/scripts/zshrc.zsh ~/.zshrc
ln -sf ~/scripts/gitconfig ~/.gitconfig
ln -sf ~/scripts/gitignore_global.zsh ~/.gitignore_global
ln -sf ~/scripts/.ssh ~/.ssh