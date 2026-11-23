function gsw --wraps='git switch' --description 'Switch branches interactively or pass arguments to git switch'
    if test (count $argv) -gt 0
        git switch $argv
        return $status
    end

    if not command -q python3
        echo 'python3 is required' >&2
        return 127
    end

    python3 "$DEV_SCRIPT_DIR/src/gsw.py" $argv
end
