function cdr --description "Change directory to the Git repository root"
    if set -l git_root (git rev-parse --show-toplevel 2>/dev/null)
        cd $git_root
    else
        echo "Not a Git repository."
        return 1
    end
end
