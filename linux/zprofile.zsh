# Resolve <repo> from the ~/.zprofile symlink target.
# readlink -f gives an absolute, fully-resolved path on Linux (GNU coreutils).
DOTFILES_DIR="$(dirname "$(readlink -f ~/.zprofile)")"
REPO_DIR="$(dirname "$DOTFILES_DIR")"

# Shared aliases
if [ -f "$REPO_DIR/lib/aliases.sh" ]; then
    . "$REPO_DIR/lib/aliases.sh"
fi

# User-local bin dirs on PATH
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
case ":$PATH:" in
    *":$HOME/bin:"*) ;;
    *) [ -d "$HOME/bin" ] && export PATH="$HOME/bin:$PATH" ;;
esac

# Cowsay greeting (matches mac flow). Skip if non-interactive.
if [[ $- == *i* ]] && command -v cowsay >/dev/null 2>&1; then
    cowsay "Hello Femi :)"
fi
