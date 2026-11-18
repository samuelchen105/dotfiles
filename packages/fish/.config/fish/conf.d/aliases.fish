# TODO:
# Re-organize most of them as autoloading functions instead
# For simple ones, use abbr 

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
alias gll='devtool git-log'
alias gl='devtool git-log -n 20'

function gbd
    nu --config ~/.config/nushell/config.nu ~/.config/nushell/scripts/gbd.nu $argv
end

# Docker
alias d='docker'
alias dk='docker-compose'
alias dku='docker-compose up -d --remove-orphans'
alias dkd='docker-compose down'
alias dkl='docker-compose logs -n 100'
alias dkrm='docker-compose rm -fs'
alias dkrs='docker-compose restart'
alias dkps='docker-compose ps -a'

function dkw --wraps='docker-compose logs -n 100 -f'
    if test (count $argv) -gt 0
        docker-compose logs -n 100 -f $argv
        return
    end

    set -l service (docker-compose ps --services | fzf)
    if test -n "$service"
        docker-compose logs -n 100 -f $service
    end
end

function drmi --description='List and delete docker images with fzf'
    # Get docker images (skip header)
    set -l images (d images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedSince}}\t{{.Size}}" | tail -n +2)

    if test (count $images) -eq 0
        echo "No docker images found."
        return
    end

    # Use fzf to select images to delete
    set -l selected_images (printf '%s\n' $images | fzf --multi --header='Select images to delete (Tab for multi-select)' --bind='tab:toggle' | awk '{print $1":"$2}')

    if test -n "$selected_images"
        echoc cyan "Deleting selected images:"
        for image in $selected_images
            echoc green "Deleting $image"
            d rmi $image
        end
    else
        echo "No images selected for deletion."
        return
    end

    echo "Pruning unused images..."
    d image prune -f
end

# K8s
alias k='kubectl'
alias kcur='kubectl config current-context'

function kuse
    set -l selected (k config get-contexts | fzf \
        --header-lines=1 \
        --nth=1 \
        --accept-nth=1 \
        --layout=reverse \
        --info=inline \
        --prompt="Select Context: ") || return

    if test -n "$selected"
        k config use $selected
    end
end

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

if test $(uname) = Darwin
    alias ov='open -a "Visual Studio Code"'
else if test $(uname) = Linux
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

function cdr --description "Change directory to the Git repository root"
    if set -l git_root (git rev-parse --show-toplevel 2>/dev/null)
        cd $git_root
    else
        echo "Not a Git repository."
        return 1
    end
end
