export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="eastwood"
plugins=(git)

source $ZSH/oh-my-zsh.sh

source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

autoload -Uz compinit
compinit