# shellcheck shell=bash

preview_help() {
  local program="${1:-}"
  local word="${2:-}"
  local executable="$program"
  local -a parents=()

  if (( $# > 2 )); then
    parents=("${@:3}")
  fi

  [[ -n "$word" && "$word" != -* ]] || return 0
  [[ "$program" == zellij-action ]] && executable=zellij
  command -v "$executable" >/dev/null 2>&1 || return 0
  case "$program" in
    nix | gh | mise | uv | chezmoi)
      run_bounded 2s "$program" "${parents[@]}" "$word" --help 2>/dev/null |
        render_limited help || true
      ;;
    brew)
      HOMEBREW_NO_AUTO_UPDATE=1 run_bounded 2s brew \
        "${parents[@]}" "$word" --help 2>/dev/null | render_limited help || true
      ;;
    docker | kubectl | helm)
      run_bounded 2s "$program" "${parents[@]}" "$word" --help 2>/dev/null |
        render_limited help || true
      ;;
    bun)
      run_bounded 2s "$program" "${parents[@]}" "$word" --help 2>/dev/null |
        render_limited help || true
      ;;
    cargo | go | npm | pnpm | direnv)
      run_bounded 2s "$program" help "$word" 2>/dev/null |
        render_limited help || true
      ;;
    nh)
      run_bounded 2s nh "${parents[@]}" "$word" --help 2>/dev/null |
        render_limited help || true
      ;;
    nixpkgs-review)
      run_bounded 2s nixpkgs-review "$word" --help 2>/dev/null |
        render_limited help || true
      ;;
    zellij)
      run_bounded 2s zellij "$word" --help 2>/dev/null |
        render_limited help || true
      ;;
    zellij-action)
      run_bounded 2s zellij action "$word" --help 2>/dev/null |
        render_limited help || true
      ;;
  esac
}
