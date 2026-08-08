# shellcheck shell=bash

normalize_group() {
  local group="${1:-}"
  group="${group#[}"
  group="${group%]}"
  printf '%s' "$group"
}

render_bat() {
  local language="${1:-txt}"
  bat \
    --color=always \
    --theme=base16 \
    --language="$language" \
    --paging=never \
    --style=plain
}

render_limited() {
  local language="${1:-txt}"
  sed -n '1,500p' | render_bat "$language"
}

run_bounded() {
  local duration="${1:-2s}"
  shift
  timeout --signal=TERM --kill-after=1s "$duration" "$@"
}

render_delta() {
  delta \
    --paging=never \
    --syntax-theme=base16 \
    --line-numbers \
    --minus-style=syntax \
    --minus-non-emph-style=syntax \
    --minus-emph-style='bold syntax' \
    --minus-empty-line-marker-style=normal \
    --plus-style=syntax \
    --plus-non-emph-style=syntax \
    --plus-emph-style='bold syntax' \
    --plus-empty-line-marker-style=normal \
    --line-numbers-minus-style=red \
    --line-numbers-zero-style=normal \
    --line-numbers-plus-style=green \
    --whitespace-error-style=magenta
}
