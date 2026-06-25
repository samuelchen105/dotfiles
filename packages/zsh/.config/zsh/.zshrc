# ===== Env & Path =====

# Homebrew
export HOMEBREW_PREFIX="/opt/homebrew"

# XDG Base Directory Specification
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
export XDG_CACHE_HOME=${XDG_CACHE_HOME:-"$HOME/.cache"}
export XDG_DATA_HOME=${XDG_DATA_HOME:-"$HOME/.local/share"}
export XDG_STATE_HOME=${XDG_STATE_HOME:-"$HOME/.local/state"}

# ~/.local/bin
path=("${HOME}/.local/bin" $path)

# Golang
if (($+commands[go])); then
  # Append go/bin to PATH
  path=("$HOME/go/bin" $path)
  # Lock go version
  alias go="$HOME/go/bin/go1.24.6"
fi

# git pager
export GIT_PAGER="delta"

# ===== Antidote & Plugins =====

# Customized antidote zstyles
zstyle ':zephyr:plugin:completion' immediate yes
zstyle ':zephyr:plugin:history' 'savehist' '200000'
zstyle ':zephyr:plugin:history' 'histsize' '50000'
zstyle ':zephyr:plugin:editor' dot-expansion yes
zstyle ':zephyr:plugin:homebrew' 'use-cache' 'yes'

# Antidote
zsh_plugins=${ZDOTDIR}/.zsh_plugins

# Lazy-load antidote from its functions directory.
fpath=("${HOMEBREW_PREFIX}/opt/antidote/share/antidote" $fpath)
autoload -Uz antidote

# Generate a new static file whenever .zsh_plugins.txt is updated.
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  antidote bundle <${zsh_plugins}.txt >|${zsh_plugins}.zsh
fi

# Source your static plugins file.
source ${zsh_plugins}.zsh

# Color
# LS_COLORS: https://github.com/trapd00r/LS_COLORS
autoload -Uz colors && colors
export CLICOLOR=1
[[ -r ~/.local/share/lscolors.sh ]] && source ~/.local/share/lscolors.sh
[[ -n ${LS_COLORS:-} ]] && zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# ===== Key Bindings =====

# history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down

# ===== Aliases =====

alias l='eza -lah --icons=auto --classify=always --group-directories-first'
alias grep='grep --color=auto'

# git
alias g='git'
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

gco() {
  if (($# > 0)); then
    git checkout "$@"
    return
  fi

  if (($+commands[devtool])); then
    devtool git-checkout
  else
    git checkout
  fi
}
compdef _git gco=git-checkout

alias gbd='nu --config ~/.config/nushell/config.nu ~/.config/nushell/scripts/gbd.nu'

gl() {
  nu --config ~/.config/nushell/config.nu ~/.config/nushell/scripts/gl.nu "$@"
}
compdef _git gl=git-log

# docker
alias d='docker'
alias dk='docker compose'
alias dku='docker compose up -d --remove-orphans'
alias dkd='docker compose down'
alias dkl='docker compose logs -n 100'
alias dkw='docker compose logs -n 100 -f'
alias dkrm='docker compose rm -fs'
alias dkrs='docker compose restart'
alias dkps='docker compose ps -a'

# kubectl
alias k='kubectl'

# mac
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias ov='open -a "Visual Studio Code"'
fi

# hardcoded helper
cdp() {
  local dir
  dir=$(find "$HOME/Workspace/Project" -mindepth 1 -maxdepth 1 -type d | fzf) || return
  cd "$dir"
}

ovp() {
  local dir
  dir=$(find "$HOME/Workspace/Project" -mindepth 1 -maxdepth 1 -type d | fzf) || return
  open -a "Visual Studio Code" "$dir"
}

# ===== Tool integrations =====

# fzf
(($+commands[fzf])) && source <(fzf --zsh)

# carapace
if (($+commands[carapace])); then
  export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
  source <(carapace _carapace zsh)
fi

# starship
# (($+commands[starship])) && eval "$(starship init zsh)"

# === Temporary Configs ===

if [[ -v commands[local-builder] ]]; then
  eval "$(local-builder completion zsh)"
fi
