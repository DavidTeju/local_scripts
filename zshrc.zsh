export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="eastwood"
plugins=(git safe-paste)

source $ZSH/oh-my-zsh.sh

source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

autoload -Uz compinit
compinit

# iTerm2 shell integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

alias python='python3'
