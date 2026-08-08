# shellcheck shell=bash

preview_ssh_host() {
  local group word realpath target
  group="$(normalize_group "${1:-}")"
  word="${2:-}"
  realpath="${3:-}"

  case "$group" in
    *host*) ;;
    *)
      preview_path "$realpath"
      return 0
      ;;
  esac
  target="${word%:}"
  [[ -n "$target" && "$target" != -* ]] || return 0
  run_bounded 2s ssh -G -- "$target" 2>/dev/null |
    render_limited ssh_config || true
}
