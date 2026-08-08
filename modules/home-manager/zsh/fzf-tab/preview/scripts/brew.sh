# shellcheck shell=bash

resolve_brew_source() {
  local group="$1"
  local word="$2"
  local prefix taps_root kind name tap user repository root path
  local -a roots=()

  prefix="$(
    HOMEBREW_NO_AUTO_UPDATE=1 run_bounded 2s brew --prefix 2>/dev/null
  )" || return 0
  taps_root="$prefix/Library/Taps"
  [[ -d "$taps_root" ]] || return 0

  case "$group" in
    *cask*) kind=Casks ;;
    *formula*) kind=Formula ;;
    *) return 0 ;;
  esac

  name="${word##*/}"
  if [[ "$word" == */*/* ]]; then
    tap="${word%/*}"
    user="${tap%%/*}"
    repository="${tap#*/}"
    roots+=("$taps_root/$user/homebrew-$repository/$kind")
  else
    for root in "$taps_root"/*/*/"$kind"; do
      [[ -d "$root" ]] && roots+=("$root")
    done
  fi

  for root in "${roots[@]}"; do
    [[ -d "$root" ]] || continue
    while IFS= read -r path; do
      printf '%s\n' "$path"
      return 0
    done < <(
      run_bounded 2s find -L "$root" -type f -name "$name.rb" -print \
        2>/dev/null || true
    )
  done
}

preview_brew() {
  local operation="${1:-}"
  local group word line source_path
  group="$(normalize_group "${2:-}")"
  word="${3:-}"

  [[ -n "$word" && "$word" != -* ]] || return 0
  command -v brew >/dev/null 2>&1 || return 0
  case "$operation" in
    info)
      if [[ "$group" == *tap* ]]; then
        HOMEBREW_NO_AUTO_UPDATE=1 run_bounded 2s brew tap-info "$word" \
          2>/dev/null |
          render_bat yaml || true
      else
        HOMEBREW_NO_AUTO_UPDATE=1 run_bounded 2s brew info "$word" \
          2>/dev/null |
          render_bat yaml || true
      fi
      ;;
    list)
      HOMEBREW_NO_AUTO_UPDATE=1 run_bounded 2s brew list "$word" 2>/dev/null |
        render_bat sh || true
      ;;
    source)
      if [[ "$group" == *tap* ]]; then
        HOMEBREW_NO_AUTO_UPDATE=1 run_bounded 2s brew tap-info "$word" \
          2>/dev/null |
          render_bat yaml || true
        return 0
      fi

      source_path="$(resolve_brew_source "$group" "$word")"
      if [[ -z "$source_path" ]]; then
        while IFS= read -r line; do
          if [[ "$line" == "From: "* ]]; then
            source_path="${line#From: }"
            [[ -e "$source_path" || -L "$source_path" ]] || source_path=""
            break
          fi
        done < <(
          HOMEBREW_NO_AUTO_UPDATE=1 run_bounded 2s brew info "$word" \
            2>/dev/null || true
        )
      fi
      preview_path "$source_path"
      ;;
  esac
}
