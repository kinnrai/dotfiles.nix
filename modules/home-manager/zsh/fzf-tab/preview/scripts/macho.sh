# shellcheck shell=bash

resolve_application_executable() {
  local application="${1:-}"
  local executable info_json

  [[ -d "$application" && "${application,,}" == *.app ]] || return 1
  info_json="$(
    plistutil -i "$application/Contents/Info.plist" -f json -o - \
      2>/dev/null || true
  )"
  executable="$(
    jq --raw-output '.CFBundleExecutable // empty' <<< "$info_json" \
      2>/dev/null || true
  )"
  [[ -n "$executable" && -f "$application/Contents/MacOS/$executable" ]] || \
    return 1
  printf '%s' "$application/Contents/MacOS/$executable"
}

preview_macho_metadata() {
  local executable="${1:-}"
  local signing_target="${2:-$executable}"
  local architectures details entitlements libraries uuids

  [[ -f "$executable" ]] || return 1
  [[ "$(file --brief --mime-type -- "$executable" 2>/dev/null || true)" == \
    application/x-mach-binary ]] || return 1

  file --brief -- "$executable"
  if command -v lipo >/dev/null 2>&1; then
    architectures="$(run_bounded 2s lipo -archs "$executable" 2>/dev/null || true)"
    [[ -n "$architectures" ]] && printf 'Architectures: %s\n' "$architectures"
  fi
  if command -v dwarfdump >/dev/null 2>&1; then
    uuids="$(run_bounded 2s dwarfdump --uuid "$executable" 2>/dev/null || true)"
    [[ -n "$uuids" ]] && printf '%s\n' "$uuids"
  fi

  if command -v codesign >/dev/null 2>&1; then
    details="$(
      run_bounded 2s codesign -dvv -- "$signing_target" 2>&1 || true
    )"
    if [[ -n "$details" && "$details" != *'not signed at all'* ]]; then
      printf '\n[Code signature]\n%s\n' "$details"
      if command -v plutil >/dev/null 2>&1; then
        entitlements="$(
          run_bounded 2s codesign -d --entitlements :- -- "$signing_target" \
            2>/dev/null |
            plutil -convert json -o - -- - 2>/dev/null |
            jq --color-output . 2>/dev/null || true
        )"
        if [[ -n "$entitlements" && "$entitlements" != '{}'* ]]; then
          printf '\n[Entitlements]\n%s\n' "$entitlements" | sed -n '1,160p'
        fi
      fi
    fi
  fi

  if command -v otool >/dev/null 2>&1; then
    libraries="$(run_bounded 2s otool -L "$executable" 2>/dev/null || true)"
    if [[ -n "$libraries" ]]; then
      printf '\n[Linked libraries]\n%s\n' "$libraries"
    fi
  fi
}

preview_macho() {
  local path="${1:-}"
  local executable

  [[ -n "$path" && ( -e "$path" || -L "$path" ) ]] || return 1
  if [[ -d "$path" && "${path,,}" == *.app ]]; then
    executable="$(resolve_application_executable "$path")" || return 1
    preview_macho_metadata "$executable" "$path"
  else
    preview_macho_metadata "$path" "$path"
  fi
}
