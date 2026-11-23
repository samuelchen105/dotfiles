# ===== Env & Path =====

set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_STATE_HOME "$HOME/.local/state"
set -gx XDG_CACHE_HOME "$HOME/.cache"

set -gx GIT_PAGER "less -RF"

set -gx DEV_SCRIPT_DIR "$HOME/.local/scripts"

# Add ~/.local/bin to path
fish_add_path "$HOME/.local/bin"

# ===== Integrations =====

# fzf theme
# https://github.com/catppuccin/fzf/blob/main/themes/catppuccin-fzf-mocha.fish
set -gx FZF_DEFAULT_OPTS "\
--color=bg+:#313244,bg:#151515,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#6C7086,label:#CDD6F4"

# homebrew
if test $(uname) = Darwin
    eval "$(/opt/homebrew/bin/brew shellenv)"
end

# fnm: the npm alternative
if command -q fnm
    fnm env --use-on-cd --shell fish | source
end

# go
if command -q go
    # Append go/bin to PATH
    fish_add_path "$HOME/go/bin"
    # # Lock go version
    # alias go="~/sdk/go1.24.6/bin/go"
end

# rust
if test -e "$HOME/.cargo/env.fish"
    source "$HOME/.cargo/env.fish"
end

# Podman's docker compatibility
# The command to run the socket: `systemctl --user enable --now podman.socket`
if command -q podman
    set -gx DOCKER_HOST "unix://$XDG_RUNTIME_DIR/podman/podman.sock"
end

# Buildpack
if command -q pack; and test -e ~/.config/pack/volume-key
    set -gx PACK_VOLUME_KEY "$(cat ~/.config/pack/volume-key)"
end
