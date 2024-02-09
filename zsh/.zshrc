# ============================================================================================
# Zim
# ============================================================================================

ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
zstyle ':zim:zmodule' use 'degit'

# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  if (( ${+commands[curl]} )); then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
fi

# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi

# Initialize modules.
source ${ZIM_HOME}/init.zsh

# ============================================================================================
# Theme
# ============================================================================================

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ============================================================================================
# Module Configurations
# ============================================================================================

# history
typeset -g HISTFILE=~/.zsh_history HISTSIZE=5000000 SAVEHIST=1000000
unsetopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# zsh-syntax-highlighting
# Set what highlighters will be used.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# LS_COLORS https://github.com/trapd00r/LS_COLORS
[[ -d ~/.local/share ]] || mkdir -p ~/.local/share
[[ -f ~/.local/share/lscolors.sh ]] || curl -fsSL https://raw.githubusercontent.com/trapd00r/LS_COLORS/master/lscolors.sh > ~/.local/share/lscolors.sh
source ~/.local/share/lscolors.sh
zstyle ":completion:*" list-colors "${(s.:.)LS_COLORS}"

# ============================================================================================
# Aliases
# ============================================================================================

# git
alias gt='git'
alias gta='git add'
alias gtaa='git add -A'
alias gtb='git branch'
alias gtba='git branch -a'
alias gtcm='git commit'
alias gtco='git checkout'
alias gtlo='git log --oneline --graph'
alias gtl9='git log --oneline --graph -9'
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
alias dkc='docker container'
alias dkcp='docker container prune -f'
alias dkps='docker ps -a'
alias dkm='docker compose'
alias dkmps='docker compose ps -a'

# kubectl
alias k='kubectl'

# ============================================================================================
# Envs
# ============================================================================================

# git pager
export GIT_PAGER="less -FX"

# homebrew
if [[ "$OSTYPE" == "darwin"* ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ~/.local/bin
export PATH="${HOME}/.local/bin:${PATH}"

# go
if command -v go &>/dev/null; then
  export PATH="$(go env GOPATH)/bin:${PATH}"
fi

# python
export PYENV_ROOT="$HOME/.pyenv"
if command -v pyenv &>/dev/null; then
  eval "$(pyenv init -)"
fi

# nodejs
export NVM_DIR="$HOME/.nvm"

# cpp
export VCPKG_ROOT="$HOME/vcpkg"

# ============================================================================================
# Auto Generated Below...
# ============================================================================================
