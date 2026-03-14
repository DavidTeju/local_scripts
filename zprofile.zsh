eval "$(/opt/homebrew/bin/brew shellenv)"

# Resolve the repo directory by following the symlink from ~/.zprofile back to the real file
# NOTE: ${0:A:h} doesn't work here because zsh sets $0 to the shell name (not the file path)
# when auto-loading .zprofile at login. Use readlink on the known symlink instead.
DOTFILES_DIR="$(dirname "$(readlink ~/.zprofile)")"

# All shell aliases live here — edit this file to add/modify aliases
if [ -f "$DOTFILES_DIR/aliases.zsh" ]; then
    . "$DOTFILES_DIR/aliases.zsh"
fi

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

cowsay -r -C "Hello Femi :)"