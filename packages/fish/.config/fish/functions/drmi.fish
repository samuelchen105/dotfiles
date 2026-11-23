# TODO: update required
function drmi --description='List and delete docker images with fzf'
    # Get docker images (skip header)
    set -l images (d images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedSince}}\t{{.Size}}" | tail -n +2)

    if test (count $images) -eq 0
        echo "No docker images found."
        return
    end

    # Use fzf to select images to delete
    set -l selected_images (printf '%s\n' $images | fzf --multi --header='Select images to delete (Tab for multi-select)' --bind='tab:toggle' | awk '{print $1":"$2}')

    if test -n "$selected_images"
        echoc cyan "Deleting selected images:"
        for image in $selected_images
            echoc green "Deleting $image"
            d rmi $image
        end
    else
        echo "No images selected for deletion."
        return
    end

    echo "Pruning unused images..."
    d image prune -f
end
