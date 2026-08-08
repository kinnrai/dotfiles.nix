# shellcheck shell=bash

preview_json() {
  local path="${1:-}"
  local size

  if [[ -f "$path" ]]; then
    size="$(wc -c < "$path")"
    if [[ "$size" =~ ^[[:space:]]*[0-9]+[[:space:]]*$ ]] &&
      (( size > 5 * 1024 * 1024 )); then
      printf 'JSON file is too large for formatted preview (%s bytes)\n' "${size//[[:space:]]/}"
      file --brief -- "$path"
      return 0
    elif run_bounded 2s jq --color-output . "$path" 2>/dev/null; then
      return 0
    fi
  fi
  preview_path "$path"
}
