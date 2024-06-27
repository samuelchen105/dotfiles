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

# kubectl
alias k='kubectl'

# mac
if test $(uname) = Darwin
    alias o.vsc="open -a Visual\ Studio\ Code"
end

# work
alias k.dev="gcloud container clusters get-credentials dipp-massimo-development-main-cluster --region asia-east1 --project dipp-massimo-development && kubectl config set-context --current --namespace platform"
alias k.stg="gcloud container clusters get-credentials dipp-massimo-staging-main-cluster --region asia-east1 --project dipp-massimo-staging && kubectl config set-context --current --namespace platform"

# ============================================================================================
# Envs
# ============================================================================================

# git pager
set -gx GIT_PAGER "less -FX"

# go
if command -q go
    fish_add_path "$(go env GOPATH)/bin"
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
