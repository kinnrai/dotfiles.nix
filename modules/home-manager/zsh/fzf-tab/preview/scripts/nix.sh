# shellcheck shell=bash

nix_store_root() {
  local path="${1:-}"

  if [[ "$path" =~ ^(/nix/store/[^/]+) ]]; then
    printf '%s' "${BASH_REMATCH[1]}"
  fi
}

preview_nix_path() {
  local candidate="${1:-}"
  local realpath="${2:-}"
  local root

  candidate="${realpath:-$candidate}"
  root="$(nix_store_root "$candidate")"
  if [[ -z "$root" || ! -e "$root" ]]; then
    preview_path "$realpath"
    return 0
  fi
  command -v nix >/dev/null 2>&1 || return 0
  command -v nix-store >/dev/null 2>&1 || return 0

  printf '[Store path]\n%s\n' "$root"
  [[ "$candidate" != "$root" ]] && printf 'Selected: %s\n' "$candidate"
  printf '\n[Size]\n'
  run_bounded 2s nix path-info \
    --size --closure-size --human-readable "$root" 2>/dev/null || true
  printf '\n[Closure]\n'
  run_bounded 2s nix-store --query --tree "$root" 2>/dev/null || true
}

preview_nix_completion() {
  local word="${2:-}"
  local realpath="${3:-}"
  shift 3
  local -a cli_words=("$@")
  local -a parents=()

  if [[ -n "$(nix_store_root "${realpath:-$word}")" ]]; then
    preview_nix_path "$word" "$realpath"
    return 0
  elif [[ -n "$realpath" ]]; then
    preview_path "$realpath"
    return 0
  fi

  if ((${#cli_words[@]} > 2)); then
    parents=("${cli_words[@]:1:${#cli_words[@]}-2}")
  fi
  preview_help nix "$word" "${parents[@]}"
}
