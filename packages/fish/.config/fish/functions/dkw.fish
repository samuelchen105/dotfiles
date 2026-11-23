function dkw --wraps='docker-compose logs -n 100 -f'
    if test (count $argv) -gt 0
        docker-compose logs -n 100 -f $argv
        return
    end

    set -l service (docker-compose ps --services | fzf --layout=reverse --border)
    if test -n "$service"
        docker-compose logs -n 100 -f $service
    end
end
