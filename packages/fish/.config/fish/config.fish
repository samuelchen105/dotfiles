# ===== Env & Path =====

# fzf theme
# https://github.com/catppuccin/fzf/blob/main/themes/catppuccin-fzf-mocha.fish
set -gx FZF_DEFAULT_OPTS "\
--color=bg+:#313244,bg:#151515,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#6C7086,label:#CDD6F4"

# ===== Aliases =====

alias srcfish='source ~/.config/fish/config.fish'
alias l='eza -lah --icons=auto --classify=always --group-directories-first'

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

alias d='docker'
alias dk='docker compose'
alias dku='docker compose up -d --remove-orphans'
alias dkd='docker compose down'
alias dkl='docker compose logs -n 100'
alias dkrm='docker compose rm -fs'
alias dkrs='docker compose restart'
alias dkps='docker compose ps -a'

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
    set -l images (docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedSince}}\t{{.Size}}" | tail -n +2)

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
            docker rmi $image
        end
    else
        echo "No images selected for deletion."
        return
    end

    echo "Pruning unused images..."
    docker image prune -f
end

# kubectl
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

# mac
if test $(uname) = Darwin
    alias ov='open -a "Visual Studio Code"'

    function __select_project
        set -l dirs (find "$HOME/Workspace/Project" -mindepth 1 -maxdepth 1 -type d)
        set -l base_names
        for dir in $dirs
            set -a base_names (basename $dir)
        end
        set -l target (printf "%s\n" $base_names | fzf) || return

        echo "$HOME/Workspace/Project/$target"
    end

    function ovp
        set -l target (__select_project) || return
        open -a "Visual Studio Code" $target
    end

    function cdp
        set -l target (__select_project) || return
        cd $target
    end
end

# misc
alias denv='export $(grep -v "^#" .env | xargs | string split " ")'

function cdr --description "Change directory to the Git repository root"
    if set -l git_root (git rev-parse --show-toplevel 2>/dev/null)
        cd $git_root
    else
        echo "Not a Git repository."
        return 1
    end
end

# ===== Tool integrations =====


# starship
if command -q starship
    starship init fish | source
end

# ===== Temporary Configs =====
