# shellcheck shell=bash

preview_man() {
  local word="${1:-}"
  local width="${FZF_PREVIEW_COLUMNS:-80}"

  [[ -n "$word" && "$word" != -* ]] || return 1
  [[ "$width" =~ ^[0-9]+$ ]] || width=80

  GROFF_NO_SGR=1 MANPAGER=cat MANWIDTH="$width" \
    run_bounded 2s man "$word" 2>/dev/null |
    col -bx | render_limited man
}

preview_manual() {
  local group word realpath
  group="$(normalize_group "${1:-}")"
  word="${2:-}"
  realpath="${3:-}"

  if [[ -n "$realpath" ]]; then
    preview_path "$realpath"
  elif [[ "$group" == *manual* ]]; then
    preview_man "$word" || true
  else
    preview_command "$group" "$word" "$realpath"
  fi
}

preview_command() {
  local group word realpath resolved
  group="$(normalize_group "${1:-}")"
  word="${2:-}"
  realpath="${3:-}"

  [[ -n "$word" && "$word" != -* ]] || return 0
  case "$group" in
    *executable\ file*)
      [[ -n "$realpath" && ( -e "$realpath" || -L "$realpath" ) ]] || return 0
      printf '%s\n' "$realpath"
      file --brief -- "$realpath"
      return 0
      ;;
    *builtin*)
      # $1 belongs to the child Zsh rather than this Bash process.
      # shellcheck disable=SC2016
      run_bounded 2s zsh -f -c \
        'unalias run-help 2>/dev/null; autoload -Uz run-help; eval "run-help ${(q)1}"' \
        zsh "$word" 2>/dev/null |
        render_limited man && return 0
      ;;
  esac

  preview_man "$word" && return 0
  resolved="$(command -v -- "$word" 2>/dev/null || true)"
  [[ -n "$resolved" ]] || return 0
  printf '%s\n' "$resolved"
  [[ -e "$resolved" ]] && file --brief -- "$resolved" || true
}
