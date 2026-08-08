# shellcheck shell=bash

preview_make() {
  local executable group word realpath line value
  local matched
  executable="${1:-make}"
  group="$(normalize_group "${2:-}")"
  word="${3:-}"
  realpath="${4:-}"

  command -v "$executable" >/dev/null 2>&1 || return 0
  case "$group" in
    *target*)
      [[ -n "$word" ]] || return 0
      run_bounded 2s "$executable" -n -- "$word" 2>/dev/null |
        render_bat sh || true
      ;;
    *variable*)
      [[ -n "$word" ]] || return 0
      {
        matched=false
        while IFS= read -r line; do
          case "$line" in
            "$word = "* | "$word := "* | "$word ::= "* | "$word ?= "* | "$word += "* | "$word != "*)
              printf '%s\n' "$line"
              matched=true
              ;;
          esac
        done < <(run_bounded 2s "$executable" -pq 2>/dev/null || true)

        # BSD make and bmake expose individual variables through -V instead
        # of GNU Make's printable database (-p).
        if [[ "$matched" == false ]]; then
          value="$(run_bounded 2s "$executable" -V "$word" 2>/dev/null || true)"
          [[ -n "$value" ]] && printf '%s = %s\n' "$word" "$value"
        fi
      } |
        render_bat sh || true
      ;;
    *file*) preview_path "$realpath" ;;
  esac
}
