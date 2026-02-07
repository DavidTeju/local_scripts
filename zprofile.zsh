eval "$(/opt/homebrew/bin/brew shellenv)"

# Resolve the repo directory by following the symlink from ~/.zprofile back to the real file
DOTFILES_DIR="${0:A:h}"

if [ -f "$DOTFILES_DIR/aliases.zsh" ]; then
    . "$DOTFILES_DIR/aliases.zsh"
fi

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
