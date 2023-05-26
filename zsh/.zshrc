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
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# zsh-syntax-highlighting
# Set what highlighters will be used.
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# LS_COLORS https://github.com/trapd00r/LS_COLORS
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
alias gtll='git log --oneline --graph'
alias gtpl='git pull --prune'
alias gtps='git push'
alias gtrb='git rebase'
alias gtrs='git restore --staged'
alias gtre='git reset'
alias gtst='git stash'
alias gtstp='git stash pop'
alias gtss='git status'

# ============================================================================================
# Envs for Interactive Shell
# ============================================================================================

export GIT_PAGER="less -FX"

# ============================================================================================
# Auto Generated Below...
# ============================================================================================
