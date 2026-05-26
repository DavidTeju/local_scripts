eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"

# ~/bin holds iterm2 helpers (imgcat, it2copy) — see install.sh.
[ -d "$HOME/bin" ] && case ":$PATH:" in *":$HOME/bin:"*) ;; *) export PATH="$HOME/bin:$PATH" ;; esac

# OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

cowsay -r -C "Hello Femi :)"
