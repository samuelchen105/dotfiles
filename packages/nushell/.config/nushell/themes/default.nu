# Retrieve the theme settings
export def main [] {
  return {
    binary: '#aa759f'
    block: '#6a9fb5'
    cell-path: '#d0d0d0'
    closure: '#75b5aa'
    custom: '#f5f5f5'
    duration: '#f4bf75'
    float: '#ac4142'
    glob: '#f5f5f5'
    int: '#aa759f'
    list: '#75b5aa'
    nothing: '#ac4142'
    range: '#f4bf75'
    record: '#75b5aa'

    string: {|v|
      if $v == "󰸞" {
        '#33a776'
      } else if $v == "󱎘" {
        '#ac4142'
      } else if ($v | str starts-with "󱦲") {
        '#f4bf75'
      } else if ($v | str starts-with "󱦳") {
        '#f4bf75'
      } else {
        '#d0d0d0'
      }
    }

    bool: {|| if $in { '#75b5aa' } else { '#f4bf75' } }

    datetime: {|| (date now) - $in |
      if $in < 1hr {
        '#eba0ac'
      } else if $in < 1day {
        '#fab387'
      } else if $in < 7day {
        '#57d38a'
      } else if $in < 28day {
        '#89b4fa'
      } else if $in < 350day {
        '#657eb8'
      } else {
        'dark_gray' 
      }
    }

    filesize: {|e|
      if $e == 0b {
        '#d0d0d0'
      } else if $e < 1mb {
        '#75b5aa'
      } else {{fg: '#6a9fb5'}}
    }

    shape_and: {fg: '#aa759f', attr: 'b'}
    shape_binary: {fg: '#aa759f', attr: 'b'}
    shape_block: {fg: '#6a9fb5', attr: 'b'}
    shape_bool: '#75b5aa'
    shape_closure: {fg: '#75b5aa', attr: 'b'}
    shape_custom: '#90a959'
    shape_datetime: {fg: '#75b5aa', attr: 'b'}
    shape_directory: '#75b5aa'
    shape_external: '#ac4142'
    shape_external_resolved: '#75b5aa'
    shape_externalarg: {fg: '#90a959', attr: 'b'}
    shape_filepath: '#75b5aa'
    shape_flag: {fg: '#6a9fb5', attr: 'b'}
    shape_float: {fg: '#ac4142', attr: 'b'}
    shape_garbage: {fg: '#FFFFFF', bg: '#FF0000', attr: 'b'}
    shape_glob_interpolation: {fg: '#75b5aa', attr: 'b'}
    shape_globpattern: {fg: '#75b5aa', attr: 'b'}
    shape_int: {fg: '#aa759f', attr: 'b'}
    shape_internalcall: {fg: '#75b5aa', attr: 'b'}
    shape_keyword: {fg: '#aa759f', attr: 'b'}
    shape_list: {fg: '#75b5aa', attr: 'b'}
    shape_literal: '#6a9fb5'
    shape_match_pattern: '#90a959'
    shape_matching_brackets: {attr: 'u'}
    shape_nothing: '#ac4142'
    shape_operator: '#f4bf75'
    shape_or: {fg: '#aa759f', attr: 'b'}
    shape_pipe: {fg: '#aa759f', attr: 'b'}
    shape_range: {fg: '#f4bf75', attr: 'b'}
    shape_raw_string: {fg: '#f5f5f5', attr: 'b'}
    shape_record: {fg: '#75b5aa', attr: 'b'}
    shape_redirection: {fg: '#aa759f', attr: 'b'}
    shape_signature: {fg: '#90a959', attr: 'b'}
    shape_string: '#90a959'
    shape_string_interpolation: {fg: '#75b5aa', attr: 'b'}
    shape_table: {fg: '#6a9fb5', attr: 'b'}
    shape_vardecl: {fg: '#6a9fb5', attr: 'u'}
    shape_variable: '#aa759f'

    foreground: '#d0d0d0'
    background: '#151515'
    cursor: '#d0d0d0'

    empty: '#6a9fb5'
    header: {fg: '#90a959', attr: 'b'}
    hints: '#505050'
    leading_trailing_space_bg: {attr: 'n'}
    row_index: {fg: '#90a959', attr: 'b'}
    search_result: {fg: '#ac4142', bg: '#d0d0d0'}
    separator: '#d0d0d0'
  }
}

# Update the Nushell configuration
export def --env "set color_config" [] {
  $env.config.color_config = (main)
}

# Update terminal colors
export def "update terminal" [] {
  let theme = (main)

  # Set terminal colors
  let osc_screen_foreground_color = '10;'
  let osc_screen_background_color = '11;'
  let osc_cursor_color = '12;'

  $"
    (ansi -o $osc_screen_foreground_color)($theme.foreground)(char bel)
    (ansi -o $osc_screen_background_color)($theme.background)(char bel)
    (ansi -o $osc_cursor_color)($theme.cursor)(char bel)
    "
  | str replace --all "\n" ''
  | print -n $"($in)\r"
}

export module activate {
  export-env {
        set color_config
        update terminal
    }
}

# Activate the theme when sourced
use activate
