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

# Projects
alias assistant='cd ~/projects/personal_assistant_claude && claude'

# Python
alias python='python3'

# Deploy
alias deploy-handwriting="ssh root@betterletters.app 'cd /root/handwriting-teacher && git pull && docker build -t handwriting-teacher . && docker stop handwriting-teacher && docker rm handwriting-teacher && docker run -d --name handwriting-teacher --restart unless-stopped -p 127.0.0.1:5123:5123 --env-file /root/handwriting-teacher/.env handwriting-teacher'"
