if status is-interactive
    # Linux only
    if test $(uname) = Linux
        # ssh agent
        if not test -S "$SSH_AUTH_SOCK"
            eval (ssh-agent -c) >/dev/null
        end
    end

    # Mac only
    if test $(uname) = Darwin
        # Add more when needed
    end

    # Buildpack
    function __gen_pack_key --description "Generate buildpack volume key"
        echo "buildpack volume key is not found, generate one to ~/.config/pack/volume-key"
        mkdir -p ~/.config/pack
        openssl rand -hex 32 >~/.config/pack/volume-key
        chmod 600 ~/.config/pack/volume-key
    end

    # Init starship
    if command -q starship
        starship init fish | source
    end
end

# ===== Temporary Configs =====
