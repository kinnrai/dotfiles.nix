# shellcheck shell=bash

preview_shellcheck() {
  local path="${1:-}"
  local output
  local check_status=0

  [[ -n "$path" && -f "$path" ]] || return 0
  command -v shellcheck >/dev/null 2>&1 || {
    preview_path "$path"
    return 0
  }
  output="$(
    run_bounded 2s shellcheck --color=always --format=tty -- "$path" 2>&1
  )" || check_status=$?
  if [[ -n "$output" ]]; then
    printf '%s\n' "$output"
  elif ((check_status == 0)); then
    printf 'No ShellCheck issues.\n\n'
    preview_text_file "$path"
  else
    # A timeout or failed invocation is not a successful lint result.
    preview_text_file "$path"
  fi
}
