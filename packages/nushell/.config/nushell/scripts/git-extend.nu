export def gco [...rest] {
  if ($rest | is-empty) {
    let b = x-git-branch
    | where h == " "
    | select branch upstream committed
    | sort-by -r committed
    | input list

    if ($b | is-not-empty) {
      $b | get branch | git checkout $in
    }
  } else {
    git checkout ...$rest
  }
}

export def gbd [
  --all (-a)
] {
  let branches = if $all {
    x-git-branch
    | where h == " " and branch != "main"
    | sort-by {|r|
        if $r.status == "gone" {
          0
        } else if $r.status == "local" {
          1
        } else if $r.status == "up-to-date" {
          2
        } else {
          3
        }
      } committed
  } else {
    x-git-branch
    | where status == "gone"
  }

  if ($branches | is-empty) {
    echo "No branches to delete."
    return
  }

  let selected_branches = $branches
  | select branch upstream committed
  | input list -m "Select branches to delete"

  if ($selected_branches | is-empty) {
    return
  }

  git branch -D ...$selected_branches.branch
}

def git-log-completer [spans: list<string>] {
  let git_spans = $spans | skip 1 | prepend log | prepend git
  do $env.config.completions.external.completer $git_spans
}

@complete git-log-completer
export def --wrapped gl [
  -n: int = 20
  ...args
] {
  if $n > 100 {
    error make {msg: "n must be less than 100"}
  }
  
  git log --pretty="%h△%s△%aN△%D" --first-parent -n $n ...$args
  | lines
  | split column "△" hash message author raw_refs
  | upsert author {|r| $r.author | split row " " | first}
  | upsert raw_refs {|r| $r.raw_refs | split row ", "}
  | insert tag {|r| $r.raw_refs | get-first-git-log-tag}
  | insert refs {|r| $r.raw_refs | get-git-log-refs}
  | upsert hash {|r|
      if $r.message !~ '.* \(#[0-9]+\)$' {
        $r.hash
      } else {
        $r.hash | light-gray
      }
    }
  | reject raw_refs
}

def x-git-branch [] {
  git for-each-ref --format "%(HEAD)△%(refname:short)△%(committerdate:unix)△%(upstream:track,nobracket)△%(upstream:remotename)" refs/heads
  | lines
  | split column "△" h branch committed raw_track raw_remote
  | upsert committed {|r| $r.committed | into datetime -f "%s"}
  | insert status {|r|
      if $r.raw_remote == "" {
        "local"
      } else if $r.raw_track == "" {
        "up-to-date"
      } else if $r.raw_track == "gone" {
        "gone"
      } else {
        "diverged"
      }
    }
  | insert ahead {|r|
      if ($r.raw_track | str contains "ahead") {
        ($r.raw_track | parse --regex 'ahead (?P<n>\d+)' | get n.0 | into int)
      } else {
        0
      }
    }
  | insert behind {|r|
      if ($r.raw_track | str contains "behind") {
        ($r.raw_track | parse --regex 'behind (?P<n>\d+)' | get n.0 | into int)
      } else {
        0
      }
    }
  | insert upstream {|r|
      if $r.status == "up-to-date" {
        "󰸞"
      } else if $r.status == "gone" {
        "󱎘"
      } else if $r.status == "diverged" {
        let ahead_text = if $r.ahead > 0 { $"󱦲($r.ahead)" } else { "" }
        let behind_text = if $r.behind > 0 { $"󱦳($r.behind)" } else { "" }
        $"($ahead_text)($behind_text)"
      } else {
        " "
      }
    }
  | reject raw_track raw_remote
}

def get-first-git-log-tag [] {
  let tag = $in
  | where {|v| $v starts-with "tag: "}
  | first

  if ($tag | is-empty) {
    return ""
  }
  $tag | str substring 5.. | yellow
}

def get-git-log-refs [] {
  $in
  | where {|v| $v not-starts-with "tag: " and $v != "origin/HEAD"}
  | reduce -f {} {|v, record|
      if ($v starts-with "HEAD") {
        let branch = ($v | split row " " | get 2)

        $record | upsert $branch {
          $in | default {} | upsert local true
        }
      } else if ($v starts-with "origin/") {
        let branch = ($v | str substring 7..)

        $record | upsert $branch {
          $in | default {} | upsert remote true
        }
      } else {
        $record | upsert $v {
          $in | default {} | upsert local true
        }
      }
    }
  | items {|branch, flags|
      match [$flags.local? $flags.remote?] {
          [true true] => ($branch | purple)
          [true _] => ($branch | green)
          [_ true] => ($branch | red)
          _ => $branch
      }
    }
  | str join ", "
}

def yellow [] {
  $"(ansi "#f9efaf")($in)(ansi reset)"
}

def blue [] {
  $"(ansi "#89b4fa")($in)(ansi reset)"
}

def green [] {
  $"(ansi "#a6e3a1")($in)(ansi reset)"
}

def red [] {
  $"(ansi "#f38ba8")($in)(ansi reset)"
}

def purple [] {
  $"(ansi "#cba6f7")($in)(ansi reset)"
}

def light-gray [] {
  $"(ansi "#959595")($in)(ansi reset)"
}
