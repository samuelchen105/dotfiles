#########
# Zinit #
#########

### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zinit-zsh/z-a-rust \
    zinit-zsh/z-a-as-monitor \
    zinit-zsh/z-a-patch-dl \
    zinit-zsh/z-a-bin-gem-node

### End of Zinit's installer chunk

#########
# Theme #
#########

# powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k
# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

###########
# Plugins #
###########

# === Trigger-load ===
# LS_COLORS
zinit ice atclone"dircolors -b LS_COLORS > clrs.zsh" \
    atpull'%atclone' pick"clrs.zsh" nocompile'!' \
    atload'zstyle ":completion:*" list-colors “${(s.:.)LS_COLORS}”'
zinit light trapd00r/LS_COLORS

# === Wait 0 ===
# auto-completions & syntax-highlighting
zinit wait lucid light-mode for \
    atinit"zicompinit; zicdreplay" \
        zdharma/fast-syntax-highlighting \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    blockf atpull'zinit creinstall -q .' \
        zsh-users/zsh-completions 

# forgit
zinit wait lucid light-mode for \
	wfxr/forgit

# === Wait 0a ===
# fzf-tab
zinit wait="0a" lucid light-mode for \
        Aloxaf/fzf-tab
# fzf-tab config
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# preview directory's content with exa when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'

# === Wait 1 ===
# history-search-multi-word
zinit wait"1" lucid for \
	b4b4r07/enhancd \
    atinit'zstyle ":history-search-multi-word" page-size "8"' \
	zdharma/history-search-multi-word 

###########
# Setopts #
###########

# history
typeset -g HISTFILE=~/.zsh_history HISTSIZE=10000 SAVEHIST=1000
setopt SHARE_HISTORY

###########
# Aliases #
###########

# ls (exa instead)
alias ls="exa -bh --color=auto"
alias l="ls"    l.='ls -d .*'   la='ls -a'   ll='ls -lbt created'
alias rm='rm -i'
alias grep="grep --colour=auto"

#########################
# Environment Variables #
#########################

export DOCKER_HOST="tcp://localhost:2327"

