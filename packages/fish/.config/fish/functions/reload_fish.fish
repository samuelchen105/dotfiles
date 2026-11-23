function reload_fish
    set -l failed 0

    for file in "$__fish_config_dir"/conf.d/*.fish
        source "$file"; or set failed 1
    end

    source "$__fish_config_dir/config.fish"; or set failed 1

    return $failed
end
