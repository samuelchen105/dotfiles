function kuse
    set -l selected (k config get-contexts | fzf \
        --header-lines=1 \
        --nth=1 \
        --accept-nth=1 \
        --layout=reverse \
        --info=inline \
        --prompt="Select Context: ") || return

    if test -n "$selected"
        k config use $selected
    end
end
