export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="eastwood"
plugins=(git safe-paste)

source $ZSH/oh-my-zsh.sh

# Resolve <repo>/lib from the symlinked ~/.zshrc.
# %N is the path of the file currently being sourced; :A makes it absolute and follows symlinks; :h is dirname.
LIB_DIR="${${(%):-%N}:A:h}"
REPO_DIR="${LIB_DIR:h}"

# Source plugins from wherever they live (brew on mac, /usr/share on Debian).
_brew_prefix=""
command -v brew >/dev/null 2>&1 && _brew_prefix="$(brew --prefix 2>/dev/null)"

for f in \
    "${_brew_prefix:+$_brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh}" \
    "${_brew_prefix:+$_brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh}" \
    /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
    /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
    /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
    /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
do
    [ -n "$f" ] && [ -r "$f" ] && source "$f"
done
unset _brew_prefix

autoload -Uz compinit
compinit

# iTerm2 shell integration (mac only — file just doesn't exist on linux)
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Shared `what` command inspector
[ -r "$LIB_DIR/what.zsh" ] && source "$LIB_DIR/what.zsh"

# copilot-bridge — Copilot subscription as OpenAI/Anthropic endpoint (Codex + Claude Code)
[ -r "$LIB_DIR/copilot-bridge.sh" ] && source "$LIB_DIR/copilot-bridge.sh"

# Shared aliases — sourced here (not just from .zprofile) so they load
# for non-login interactive shells too (common on Linux terminals).
[ -r "$LIB_DIR/aliases.sh" ] && source "$LIB_DIR/aliases.sh"

# Secrets from <repo>/.env (gitignored). `set -a` auto-exports every var defined
# until `set +a` — handles quoted values and whitespace, unlike `xargs`-based loaders.
if [ -f "$REPO_DIR/.env" ]; then
    set -a
    . "$REPO_DIR/.env"
    set +a
fi

# Bun — global package binaries (e.g. ynab-cli)
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
