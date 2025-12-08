# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~="cd ~"
alias -- -='cd -'

# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
	colorflag="--color"
else # macOS `ls`
	colorflag="-G"
fi

alias ls="ls ${colorflag}"
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# File Operations (Safety)
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias mkdir='mkdir -p'

# System Info
alias df='df -h'
alias du='du -h'

# Search
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Tree
alias tree1='tree -L 1'
alias tree2='tree -L 2'
alias tree3='tree -L 3'

# History
alias h='history'

# Clear
alias cls='clear'

# Reload shell
alias reload='source ~/.zprofile && source ~/.zshrc'
