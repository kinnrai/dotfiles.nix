# shellcheck shell=bash

resolve_node_project_dir() {
  local manager="${1:-}"
  shift
  local -a cli_words=("$@")
  local directory="$PWD"
  local index token

  for ((index = 1; index + 1 < ${#cli_words[@]}; index++)); do
    token="${cli_words[index]}"
    case "$manager:$token" in
      pnpm:-C | pnpm:--dir | npm:--prefix)
        directory="${cli_words[index + 1]}"
        ((index += 1))
        ;;
      pnpm:--dir=* | npm:--prefix=*) directory="${token#*=}" ;;
    esac
  done

  (cd -- "$directory" 2>/dev/null && pwd -P) || printf '%s' "$PWD"
}

find_node_project_root() {
  local current="${1:-$PWD}"
  local fallback="" parent

  while [[ -n "$current" ]]; do
    [[ -z "$fallback" && -f "$current/package.json" ]] && fallback="$current"
    if [[ -f "$current/pnpm-workspace.yaml" || -f "$current/pnpm-workspace.yml" ]]; then
      printf '%s' "$current"
      return 0
    elif [[ -f "$current/package.json" ]] && \
      jq --exit-status '.workspaces? != null' "$current/package.json" \
        >/dev/null 2>&1; then
      printf '%s' "$current"
      return 0
    fi
    [[ "$current" == / ]] && break
    parent="${current%/*}"
    [[ -n "$parent" ]] || parent=/
    current="$parent"
  done
  printf '%s' "$fallback"
}

preview_node_manifest_matches() {
  local root="${1:-}"
  local mode="${2:-}"
  local word="${3:-}"
  local manifest data
  local count=0 matches=0

  [[ -n "$root" && -n "$word" ]] || return 1
  while IFS= read -r -d '' manifest; do
    ((count += 1))
    ((count <= 200)) || break
    case "$mode" in
      script)
        data="$(
          jq --compact-output --arg name "$word" '
            select(.scripts[$name] != null) | {
              package: (.name // "<unnamed>"),
              version: (.version // null),
              script: $name,
              command: .scripts[$name]
            }
          ' "$manifest" 2>/dev/null || true
        )"
        ;;
      package)
        data="$(
          jq --compact-output --arg name "$word" '
            select(.name == $name) | {
              name,
              version: (.version // null),
              description: (.description // null),
              private: (.private // false),
              scripts: ((.scripts // {}) | keys)
            }
          ' "$manifest" 2>/dev/null || true
        )"
        ;;
      *) return 1 ;;
    esac
    [[ -n "$data" ]] || continue
    ((matches += 1))
    ((matches > 1)) && printf '\n'
    printf '[%s]\n' "${manifest#"$root"/}"
    jq --color-output . <<< "$data"
  done < <(
    run_bounded 2s find "$root" \
      \( -name .git -o -name node_modules -o -name .direnv \) -prune -o \
      -name package.json -type f -print0 2>/dev/null || true
  )

  ((matches > 0))
}

preview_node_completion() {
  local manager="${1:-}"
  local word="${3:-}"
  local realpath="${4:-}"
  shift 4
  local -a cli_words=("$@")
  local -a positionals=()
  local directory root token last_token lookup_word="$word"
  local index skip_next=0 filter_candidate=false

  [[ "$manager" == pn ]] && manager=pnpm
  if [[ -n "$realpath" ]]; then
    preview_path "$realpath"
    return 0
  fi

  directory="$(resolve_node_project_dir "$manager" "${cli_words[@]}")"
  root="$(find_node_project_root "$directory")"
  for ((index = 1; index + 1 < ${#cli_words[@]}; index++)); do
    token="${cli_words[index]}"
    if ((skip_next)); then
      skip_next=0
      continue
    fi
    case "$token" in
      -C | --dir | --prefix | --filter | -F | --workspace | -w)
        [[ "$token" =~ ^(--filter|-F|--workspace|-w)$ ]] && \
          ((index + 1 == ${#cli_words[@]} - 1)) && filter_candidate=true
        skip_next=1
        ;;
      --dir=* | --prefix=*) ;;
      --filter=* | --workspace=*) filter_candidate=true ;;
      -*) ;;
      *) positionals+=("$token") ;;
    esac
  done
  last_token="${cli_words[-1]:-}"
  case "$last_token" in
    --filter=* | --workspace=*)
      filter_candidate=true
      lookup_word="${word#*=}"
      ;;
    -F*)
      filter_candidate=true
      lookup_word="${word#-F}"
      ;;
  esac

  if [[ "${positionals[0]:-}" =~ ^(run|run-script)$ ]] && \
    preview_node_manifest_matches "$root" script "$word"; then
    return 0
  fi
  if [[ "$filter_candidate" == true ]] && \
    preview_node_manifest_matches "$root" package "$lookup_word"; then
    return 0
  fi

  preview_help "$manager" "$word" "${positionals[@]}"
}
