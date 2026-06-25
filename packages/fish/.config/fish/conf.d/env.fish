# ===== Env =====

set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_STATE_HOME "$HOME/.local/state"
set -gx XDG_CACHE_HOME "$HOME/.cache"

set -gx GIT_PAGER delta

# ===== Path =====

# ~/.local/bin
fish_add_path "$HOME/.local/bin"

# ===== Integrations =====

# homebrew
if test $(uname) = Darwin
    eval "$(/opt/homebrew/bin/brew shellenv)"
end

# fnm
if command -q fnm
    fnm env --use-on-cd --shell fish | source
end

# go
if command -q go
    # Append go/bin to PATH
    fish_add_path "$HOME/go/bin"
    # Lock go version
    alias go="~/sdk/go1.24.6/bin/go"
    if test $(uname) = Darwin
    end
end

# rust
if test -e "$HOME/.cargo/env.fish"
    source "$HOME/.cargo/env.fish"
end
