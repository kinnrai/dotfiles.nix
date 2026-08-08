# shellcheck shell=bash

preview_defaults() {
  local mode="${1:-}"
  local group word domain
  group="$(normalize_group "${2:-}")"
  word="${3:-}"
  domain="${4:-}"

  [[ -n "$word" ]] || return 0
  command -v defaults >/dev/null 2>&1 || return 0
  if [[ "$group" == *application* ]]; then
    run_bounded 2s defaults read -app "$word" 2>/dev/null |
      render_limited txt || true
  elif [[ "$mode" == key && -n "$domain" ]]; then
    run_bounded 2s defaults read "$domain" "$word" 2>/dev/null |
      render_limited txt || true
  else
    run_bounded 2s defaults read "$word" 2>/dev/null |
      render_limited txt || true
  fi
}

preview_defaults_completion() {
  local group="${1:-}"
  local word="${2:-}"
  local realpath="${3:-}"
  shift 3
  local -a cli_words=("$@")
  local subcommand="${cli_words[1]:-}"

  if [[ -n "$realpath" ]]; then
    preview_path "$realpath"
  elif [[ "$subcommand" =~ ^(read|read-type|write|rename|delete)$ ]]; then
    if ((${#cli_words[@]} <= 3)); then
      preview_defaults domain "$group" "$word"
    else
      preview_defaults key "$group" "$word" "${cli_words[2]:-}"
    fi
  fi
}

preview_sysctl() {
  local word="${1:-}"
  local description

  [[ -n "$word" && "$word" != -* && "$word" != *=* ]] || return 0
  if [[ "$OSTYPE" == darwin* ]]; then
    description="$(sysctl -d "$word" 2>/dev/null || true)"
    [[ -n "${description#*: }" ]] && printf '%s\n' "$description"
  fi
  sysctl "$word" 2>/dev/null || true
}

preview_network_service() {
  local word="${1:-}"

  [[ -n "$word" ]] || return 0
  command -v networksetup >/dev/null 2>&1 || return 0
  printf '[Info]\n'
  networksetup -getinfo "$word" 2>/dev/null || true
  printf '\n[Enabled]\n'
  networksetup -getnetworkserviceenabled "$word" 2>/dev/null || true
  printf '\n[DNS]\n'
  networksetup -getdnsservers "$word" 2>/dev/null || true
  printf '\n[Search domains]\n'
  networksetup -getsearchdomains "$word" 2>/dev/null || true
}

preview_network_device() {
  local word="${1:-}"

  [[ -n "$word" ]] || return 0
  command -v networksetup >/dev/null 2>&1 || return 0
  networksetup -getmacaddress "$word" 2>/dev/null || true
  networksetup -getMTU "$word" 2>/dev/null || true
  networksetup -getMedia "$word" 2>/dev/null || true
}

preview_networksetup() {
  local option group word
  option="${1:-}"
  group="$(normalize_group "${2:-}")"
  word="${3:-}"

  case "$option" in
    -getinfo | -getnetworkserviceenabled | -getdnsservers | -getsearchdomains)
      preview_network_service "$word"
      ;;
    -getmacaddress | -getMTU | -getMedia)
      preview_network_device "$word"
      ;;
    *)
      case "$group" in
        *service*) preview_network_service "$word" ;;
        *device* | *hardware\ port*) preview_network_device "$word" ;;
      esac
      ;;
  esac
}

preview_metadata() {
  local kind="${1:-}"
  local path="${2:-}"

  # df completes mount points/device names without compadd's file flag, so
  # fzf-tab does not populate realpath. Other tools still require a file match.
  [[ "$kind" != df || -n "$path" ]] || path="${3:-}"

  [[ -n "$path" && ( -e "$path" || -L "$path" ) ]] || return 0
  case "$kind" in
    plutil)
      preview_plist "$path" || preview_path "$path"
      ;;
    mdls)
      command -v mdls >/dev/null 2>&1 || return 0
      run_bounded 2s mdls -- "$path" 2>/dev/null | render_limited log || true
      ;;
    xattr)
      command -v xattr >/dev/null 2>&1 || return 0
      run_bounded 2s xattr -l -- "$path" 2>/dev/null | render_limited log || true
      ;;
    stat | du | df | readlink)
      case "$kind" in
        stat) stat -- "$path" 2>/dev/null || true ;;
        du) du -sh -- "$path" 2>/dev/null || true ;;
        df) df -h -- "$path" 2>/dev/null || true ;;
        readlink) readlink -- "$path" 2>/dev/null || preview_path "$path" ;;
      esac
      ;;
  esac
}

preview_otool() {
  local path="${1:-}"

  [[ -n "$path" && ( -e "$path" || -L "$path" ) ]] || return 0
  command -v otool >/dev/null 2>&1 || {
    preview_path "$path"
    return 0
  }

  preview_macho "$path" || preview_path "$path"
}
