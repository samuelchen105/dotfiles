function gco --wraps='git checkout'
    if test (count $argv) -gt 0
        git checkout $argv
        return
    end

    devtool git-checkout
end
