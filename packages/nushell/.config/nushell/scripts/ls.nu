#!/usr/bin/env nu

def main [...args] {
  if ($args | is-empty) {
    ls -al
  } else {
    ls -al ...$args
  }
  | select name type mode size modified user
  | sort-by type name
}
