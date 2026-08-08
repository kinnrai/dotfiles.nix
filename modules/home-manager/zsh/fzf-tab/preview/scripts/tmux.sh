# shellcheck shell=bash

preview_tmux() {
  local operation="${1:-}"
  local word="${2:-}"
  local index token
  local -a command_words=() server=() scope=()

  if (( $# > 2 )); then
    command_words=("${@:3}")
  fi

  command -v tmux >/dev/null 2>&1 || return 0
  for ((index = 0; index < ${#command_words[@]}; index++)); do
    token="${command_words[index]}"
    case "$token" in
      -L | -S)
        if (( index + 1 < ${#command_words[@]} )) &&
          [[ -n "${command_words[index + 1]}" ]]; then
          server+=("$token" "${command_words[index + 1]}")
          ((index += 1))
        fi
        ;;
      -L?* | -S?*) server+=("$token") ;;
      -g)
        [[ "$operation" != buffer ]] && scope+=(-g)
        ;;
      -p | -w)
        [[ "$operation" == hook || "$operation" == option ]] && scope+=("$token")
        ;;
      -s)
        [[ "$operation" == option ]] && scope+=(-s)
        ;;
      -t)
        if (( index + 1 < ${#command_words[@]} )) &&
          [[ -n "${command_words[index + 1]}" ]]; then
          scope+=(-t "${command_words[index + 1]}")
          ((index += 1))
        fi
        ;;
      -t?*) scope+=("$token") ;;
    esac
  done

  case "$operation" in
    command)
      command tmux "${server[@]}" list-commands "$word" 2>/dev/null |
        render_bat help || true
      ;;
    environment)
      command tmux "${server[@]}" show-environment "${scope[@]}" "$word" \
        2>/dev/null |
        render_bat sh || true
      ;;
    hook)
      command tmux "${server[@]}" show-hooks "${scope[@]}" 2>/dev/null |
        rg --fixed-strings -- "$word" |
        render_bat sh || true
      ;;
    option)
      command tmux "${server[@]}" show-options -q "${scope[@]}" "$word" \
        2>/dev/null |
        render_bat tsv || true
      ;;
    window-option)
      command tmux "${server[@]}" show-options -wq "${scope[@]}" "$word" \
        2>/dev/null |
        render_bat tsv || true
      ;;
    buffer)
      command tmux "${server[@]}" show-buffer -b "$word" 2>/dev/null || true
      ;;
  esac
}
