# Shared aliases — sourced from lib/zshrc.zsh after oh-my-zsh, plus
# linux/bashrc.sh for bash sessions.

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~="cd ~"
alias -- -='cd -'

# Detect which `ls` flavor is in use. Use `--version` because BSD ls silently
# accepts `--color` (returns 0) but breaks symlink-following when given.
if command ls --version > /dev/null 2>&1; then # GNU `ls`
    colorflag="--color"
else # macOS BSD `ls`
    colorflag="-G"
fi

alias ls="command ls ${colorflag}"
alias ll='ls -alFH'
alias la='ls -AH'
alias l='ls -CFH'

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

# Reload shell — picks the right files based on which shell we're in
if [ -n "$ZSH_VERSION" ]; then
    alias reload='source ~/.zprofile && source ~/.zshrc'
else
    alias reload='source ~/.bashrc'
fi

# apt shortcuts (Linux-only; inert on mac)
if command -v apt-get >/dev/null 2>&1; then
    alias agi='sudo apt-get install -y'
    alias agu='sudo apt-get update && sudo apt-get upgrade -y'
    alias ags='apt-cache search'
fi

# Projects
alias assistant='cd ~/projects/personal_assistant_claude && claude'

# Beeper (wrapper with contact enrichment)
alias beeper='~/projects/personal_assistant_claude/scripts/beeper'

# Python
alias python='python3'

# Deploy
alias deploy-handwriting="ssh root@betterletters.app 'cd /root/handwriting-teacher && git pull && docker build -t handwriting-teacher . && docker stop handwriting-teacher && docker rm handwriting-teacher && docker run -d --name handwriting-teacher --restart unless-stopped -p 127.0.0.1:5123:5123 --env-file /root/handwriting-teacher/.env handwriting-teacher'"
