# ============================================================================================
# Package Manager & Tool Path
# ============================================================================================

# homebrew
if test $(uname) = Darwin
    eval "$(/opt/homebrew/bin/brew shellenv)"
end

# ~/.local/bin
fish_add_path "$HOME/.local/bin"

# ============================================================================================
# Interactive
# ============================================================================================

if status is-interactive
    # install fisher
    if not functions -q fisher
        curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
    end

    # install plugins
    set plugins \
        IlanCosman/tide@v6 \
        jorgebucaran/nvm.fish \
        edc/bass

    for plugin in $plugins
        if not fisher list "^$(string lower $plugin)\$" &>/dev/null
            fisher install $plugin
        end
    end
end

# ============================================================================================
# Aliases
# ============================================================================================

# helper functions
function echoc -a color message --description='Print message with color'
    echo (set_color $color)"$message"(set_color normal)
end

# eza/exa
if command -q eza
    alias ls='eza --group-directories-first'
else if command -q exa
    alias ls='exa --group-directories-first'
else
    echo 'eza not installed'
    return 1
end

alias ll='ls -l --git' # Long format, git status
alias l='ll -a' # Long format, all files
alias lr='l -T' # Long format, recursive as a tree
alias lx='l -sextension' # Long format, sort by extension
alias lk='l -ssize' # Long format, largest file size last
alias lt='l -smodified' # Long format, newest modification time last
alias lc='l -schanged' # Long format, newest status change (ctime) last

# git
alias gt='git'
alias gta='git add'
alias gtaa='git add -A'
alias gtb='git branch'
alias gtba='git branch -a'
alias gtcm='git commit'
alias gtco='git checkout'
alias gtl='git log --oneline --graph'
alias gtll='git log --oneline --graph -20'
alias gtlt='git log --tags --simplify-by-decoration --pretty="%C(auto)%h %s%d" -10'
alias gtpl='git pull --prune'
alias gtps='git push'
alias gtrb='git rebase'
alias gtrs='git restore --staged'
alias gtre='git reset'
alias gtst='git stash'
alias gtstp='git stash pop'
alias gtss='git status'

function gc -a branch_name --wraps='git checkout'
    if test -n "$branch_name"
        git checkout $branch_name
        return
    end

    set -l branch_name (git branch | fzf)
    if test -n "$branch_name"
        git checkout (string trim --chars='* ' $branch_name)
    end
end

function gbd --description='List and delete git branches with deleted upstream branches'
    # Get branches with deleted upstream (marked as [gone])
    set -l gone_branches (git branch -vv | grep ': gone]' | awk '{print $1}' | string trim --chars='* ')

    if test (count $gone_branches) -eq 0
        echo "No branches with deleted upstream found."
        return
    end

    # Use fzf to select branches to delete
    set -l selected_branches (printf '%s\n' $gone_branches | fzf --multi --preview='git log --oneline --graph -10 {}' --header='Select branches to delete (Tab for multi-select)')

    if test -n "$selected_branches"
        echoc cyan "Deleting selected branches:"
        for branch in $selected_branches
            echoc green "Deleting $branch"
            git branch -D $branch
        end
    else
        echo "No branches selected for deletion."
    end
end

# docker
alias dk='docker'
alias dki='docker image'
alias dkil='docker images'
alias dkip='docker image prune -f'
alias dkir='docker rmi'
alias dkc='docker container'
alias dkcp='docker container prune -f'
alias dkps='docker ps -a'
alias dkm='docker compose'
alias dkmps='docker compose ps -a'

function dl
    set service (docker-compose config --services | fzf)
    if test -n "$service"
        docker-compose logs -n 100 -f $service
    end
end

function drmi --description='List and delete docker images with fzf'
    # Get docker images (skip header)
    set -l images (docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedAt}}\t{{.Size}}" | tail -n +2)

    if test (count $images) -eq 0
        echo "No docker images found."
        return
    end

    # Use fzf to select images to delete
    set -l selected_images (printf '%s\n' $images | fzf --multi --header-lines=0 --preview='docker inspect {3}' --header='Select images to delete (Tab for multi-select)' --bind='tab:toggle+up' | awk '{print $1":"$2}')

    if test -n "$selected_images"
        echoc cyan "Deleting selected images:"
        for image in $selected_images
            echoc green "Deleting $image"
            docker rmi $image
        end
    else
        echo "No images selected for deletion."
    end
end

# mac
if test $(uname) = Darwin
    alias ovsc='open -a Visual\ Studio\ Code'
    alias oc='open -a Cursor'
    alias ocp='open -a Cursor ~/Workspace/Project/$(ls -D ~/Workspace/Project | fzf)'
end

# work
alias k='kubectl'
alias k.dev='gcloud container clusters get-credentials dipp-massimo-development-main-cluster --region asia-east1 --project dipp-massimo-development && kubectl config set-context --current --namespace platform'
alias k.stg='gcloud container clusters get-credentials dipp-massimo-staging-main-cluster --region asia-east1 --project dipp-massimo-staging && kubectl config set-context --current --namespace platform'

# misc
alias cdp='cd ~/Workspace/Project/$(ls -D ~/Workspace/Project | fzf)'
alias denv='export $(grep -v "^#" .env | xargs | string split " ")'

# ============================================================================================
# Envs
# ============================================================================================

# git pager
set -gx GIT_PAGER "less -FX"

# go
if command -q go
    fish_add_path "$(go env GOPATH)/bin"

    # lock go version
    if test $(uname) = Darwin
        alias go="$(brew --prefix go@1.23)/bin/go"
    end
end

# python
if command -q pyenv
    set -gx PYENV_ROOT "$HOME/.pyenv"
    eval "$(pyenv init -)"
end
set -gx OPENBLAS $(brew --prefix openblas)

# nodejs
set -gx NVM_DIR $(brew --prefix nvm)

# cpp
set -gx VCPKG_ROOT "$HOME/vcpkg"

# gcloud
if test -e "$(brew --prefix)/share/google-cloud-sdk/path.bash.inc"
    bass source "$(brew --prefix)/share/google-cloud-sdk/path.bash.inc"
end
if test -e "$(brew --prefix)/share/google-cloud-sdk/completion.bash.inc"
    bass source "$(brew --prefix)/share/google-cloud-sdk/completion.bash.inc"
end
