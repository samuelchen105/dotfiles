def main [
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
