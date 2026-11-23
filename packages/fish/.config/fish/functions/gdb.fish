function gdb --description 'Delete branches interactively'
    if not command -q python3
        echo 'python3 is required' >&2
        return 127
    end

    python3 "$DEV_SCRIPT_DIR/src/gdb.py" $argv
end
