# ============================================================================================
# Zinit
# ============================================================================================

if [[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/zi/init.zsh" ]]; then
  source "${XDG_CONFIG_HOME:-$HOME/.config}/zi/init.zsh" && zzinit
fi

# ============================================================================================
# Theme
# ============================================================================================

# powerlevel10k
zi ice depth=1; zi light romkatv/powerlevel10k
# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ============================================================================================
# Plugins
# ============================================================================================

# === Trigger-load ===
# LS_COLORS
zi ice atclone"dircolors -b LS_COLORS > clrs.zsh" \
    atpull'%atclone' pick"clrs.zsh" nocompile'!' \
    atload'zstyle ":completion:*" list-colors “${(s.:.)LS_COLORS}”'
zi light trapd00r/LS_COLORS

# === Wait 0 ===
# auto-completions & syntax-highlighting
zi wait lucid light-mode for \
    atinit"zicompinit; zicdreplay" \
        zdharma/fast-syntax-highlighting \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    blockf atpull'zi creinstall -q .' \
        zsh-users/zsh-completions 

# forgit
zi wait lucid light-mode for \
	wfxr/forgit

# === Wait 1 ===
# history-search-multi-word
zi wait"1" lucid for \
    atinit'zstyle ":history-search-multi-word" page-size "8"' \
	zdharma/history-search-multi-word 

# ============================================================================================
# Setopts
# ============================================================================================

# history
typeset -g HISTFILE=~/.zsh_history HISTSIZE=5000000 SAVEHIST=1000000
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# ============================================================================================
# Aliases
# ============================================================================================

# ls (exa instead)
alias ls='exa -bh --color=auto'
alias l='ls'
alias la='ls -a'
alias ll='ls -al'
alias rm='rm -i'
alias grep='grep --colour=auto'

# git
alias gt='git'
alias gta='git add'
alias gtaa='git add -A'
alias gtb='git branch'
alias gtba='git branch -a'
alias gtcm='git commit'
alias gtco='git checkout'
alias gtll='git log --oneline --graph -10'
alias gtpl='git pull --prune'
alias gtps='git push'
alias gtrb='git rebase'
alias gtrs='git restore --staged'
alias gtre='git reset'
alias gtst='git stash'
alias gtstp='git stash pop'
alias gtss='git status'

# ============================================================================================
# Auto Generated Below...
# ============================================================================================
