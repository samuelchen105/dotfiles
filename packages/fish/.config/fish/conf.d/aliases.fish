alias l='eza -lah --icons=auto --classify=always --group-directories-first'

# Git
alias ga='git add'
alias gaa='git add -A'
alias gss='git status'
alias gb='git branch'
alias gba='git branch -a'
alias gcm='git commit'
alias gpl='git pull origin --prune'
alias gps='git push'
alias grb='git rebase'
alias grs='git restore --staged'
alias gre='git reset'
alias gst='git stash'
alias gstp='git stash pop'
alias gl='gll -n 20'

# Docker
alias d='docker'
alias dk='docker-compose'
alias dku='docker-compose up -d --remove-orphans'
alias dkd='docker-compose down'
alias dkl='docker-compose logs -n 100'
alias dkrm='docker-compose rm -fs'
alias dkrs='docker-compose restart'
alias dkps='docker-compose ps -a'

# K8s
alias k='kubectl'
alias kcur='kubectl config current-context'

# Quick file/folder opening
function __select_project
    set -l workspace_root "$HOME/workspace"
    set -l dirs (find "$workspace_root" -mindepth 1 -maxdepth 1 -type d)
    set -l base_names
    for dir in $dirs
        set -a base_names (basename $dir)
    end
    set -l target (printf "%s\n" $base_names | fzf) || return

    echo "$workspace_root/$target"
end

switch $(uname)
    case Darwin
        alias ov='open -a "Visual Studio Code"'
    case Linux
        alias ov='code'
end

function cdp
    set -l target (__select_project) || return
    cd $target
end

function ovp
    set -l target (__select_project) || return
    ov $target
end

# Package manager
if test $(uname) = Linux
    alias dnf='sudo dnf'
end

# Misc
alias denv='export $(grep -v "^#" .env | xargs | string split " ")'
