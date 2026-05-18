# bash entrypoint, sourced from ~/.bashrc when zsh isn't the login shell.

DOTFILES_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
REPO_DIR="$(dirname "$DOTFILES_DIR")"

# Shared aliases + `what` function
[ -f "$REPO_DIR/lib/aliases.sh" ] && . "$REPO_DIR/lib/aliases.sh"
[ -f "$REPO_DIR/lib/what.sh" ]    && . "$REPO_DIR/lib/what.sh"

# Secrets from <repo>/.env (gitignored). `set -a` auto-exports every var defined
# until `set +a` — handles quoted values and whitespace, unlike `xargs`-based loaders.
if [ -f "$REPO_DIR/.env" ]; then
    set -a
    . "$REPO_DIR/.env"
    set +a
fi

# User-local bin dirs on PATH
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) export PATH="$HOME/.local/bin:$PATH" ;; esac
[ -d "$HOME/bin" ] && case ":$PATH:" in *":$HOME/bin:"*) ;; *) export PATH="$HOME/bin:$PATH" ;; esac
