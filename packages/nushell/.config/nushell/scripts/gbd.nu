#!/usr/bin/env nu

def main [
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
