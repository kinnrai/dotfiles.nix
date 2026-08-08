# shellcheck shell=bash

preview_tree() {
  local path="${1:-}"

  eza \
    --tree \
    --level=2 \
    --color=always \
    --icons=always \
    --group-directories-first \
    -- "$path" | sed -n '1,500p'
}

preview_text_file() {
  local path="${1:-}"

  bat \
    --color=always \
    --theme=base16 \
    --style=numbers \
    --line-range=:500 \
    -- "$path"
}

preview_image() {
  local path="${1:-}"
  local width="${FZF_PREVIEW_COLUMNS:-80}"
  local height="${FZF_PREVIEW_LINES:-24}"

  [[ "$width" =~ ^[0-9]+$ ]] || width=80
  [[ "$height" =~ ^[0-9]+$ ]] || height=24
  ((width > 0)) || width=80
  ((height > 0)) || height=24

  run_bounded 2s chafa \
    --format=symbols \
    --animate=off \
    --probe=off \
    --polite=on \
    --relative=off \
    --size="${width}x${height}" \
    -- "$path" 2>/dev/null
}

preview_archive() {
  local path="${1:-}"

  run_bounded 2s bsdtar -t --file "$path" 2>/dev/null | sed -n '1,500p'
}

preview_plist() {
  local path="${1:-}"

  run_bounded 2s plistutil -i "$path" -f json -o - 2>/dev/null |
    render_limited json
}

preview_application() {
  local path="${1:-}"
  local info_plist="$path/Contents/Info.plist"
  local executable info_json key value

  if [[ -f "$info_plist" ]]; then
    info_json="$(run_bounded 2s plistutil -i "$info_plist" -f json -o - 2>/dev/null || true)"
    while IFS=$'\t' read -r key value; do
      [[ -n "$key" ]] && printf '%-28s %s\n' "$key" "$value"
    done < <(
      jq --raw-output '
        [
          "CFBundleDisplayName",
          "CFBundleName",
          "CFBundleIdentifier",
          "CFBundleShortVersionString",
          "CFBundleVersion",
          "CFBundleExecutable"
        ][] as $key
        | select(.[$key] != null and .[$key] != "")
        | [$key, (.[$key] | tostring)]
        | @tsv
      ' <<< "$info_json" 2>/dev/null || true
    )
    [[ -n "$info_json" ]] && printf '\n'
    executable="$(
      jq --raw-output '.CFBundleExecutable // empty' <<< "$info_json" \
        2>/dev/null || true
    )"
    if [[ -n "$executable" && -f "$path/Contents/MacOS/$executable" ]]; then
      preview_macho_metadata "$path/Contents/MacOS/$executable" "$path"
      printf '\n'
    fi
  fi
  preview_tree "$path"
}

preview_regular_file() {
  local path="${1:-}"
  local mime_type

  mime_type="$(file --brief --mime-type -- "$path" 2>/dev/null || true)"
  case "$mime_type" in
    application/vnd.sqlite3 | application/x-sqlite3)
      preview_sqlite "$path" || file --brief -- "$path"
      ;;
    application/x-mach-binary)
      preview_macho "$path" || file --brief -- "$path"
      ;;
    image/*)
      preview_image "$path" || file --brief -- "$path"
      ;;
    application/json | application/*+json)
      run_bounded 2s jq --color-output . -- "$path" 2>/dev/null |
        sed -n '1,500p' || preview_text_file "$path"
      ;;
    application/x-plist)
      preview_plist "$path" || preview_text_file "$path"
      ;;
    application/zip | application/x-7z-compressed | application/x-rar | \
      application/vnd.rar | application/x-tar | application/gzip | \
      application/x-gzip | application/x-bzip2 | application/x-xz | \
      application/zstd)
      preview_archive "$path" || preview_text_file "$path"
      ;;
    *)
      case "${path,,}" in
        *.plist)
          preview_plist "$path" || preview_text_file "$path"
          ;;
        *.db | *.db3 | *.sqlite | *.sqlite3)
          preview_sqlite "$path" || file --brief -- "$path"
          ;;
        *.7z | *.rar | *.tar | *.tar.gz | *.tgz | *.tar.bz2 | *.tbz | \
          *.tbz2 | *.tar.xz | *.txz | *.tar.zst | *.tzst | *.zip)
          preview_archive "$path" || preview_text_file "$path"
          ;;
        *)
          if [[ "$mime_type" == text/* ]]; then
            preview_text_file "$path"
          else
            file --brief -- "$path"
          fi
          ;;
      esac
      ;;
  esac
}

preview_path() {
  local path="${1:-}"

  if [[ -z "$path" ]]; then
    return 0
  elif [[ -d "$path" && "${path,,}" == *.app ]]; then
    preview_application "$path"
  elif [[ -d "$path" ]]; then
    preview_tree "$path"
  elif [[ -f "$path" ]]; then
    preview_regular_file "$path"
  elif [[ -e "$path" || -L "$path" ]]; then
    file --brief -- "$path"
  fi
}
