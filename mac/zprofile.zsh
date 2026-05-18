eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"

# Resolve <repo> from the ~/.zprofile symlink target.
# NOTE: ${0:A:h} doesn't work here because zsh sets $0 to the shell name (not the file path)
# when auto-loading .zprofile at login. Use readlink on the known symlink instead.
DOTFILES_DIR="$(dirname "$(readlink ~/.zprofile)")"
REPO_DIR="$(dirname "$DOTFILES_DIR")"

# Shared aliases
if [ -f "$REPO_DIR/lib/aliases.sh" ]; then
    . "$REPO_DIR/lib/aliases.sh"
fi

# ~/bin holds iterm2 helpers (imgcat, it2copy) — see install.sh.
[ -d "$HOME/bin" ] && case ":$PATH:" in *":$HOME/bin:"*) ;; *) export PATH="$HOME/bin:$PATH" ;; esac

# OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

cowsay -r -C "Hello Femi :)"
