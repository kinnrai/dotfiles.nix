# shellcheck shell=bash

resolve_bun_project_dir() {
  local -a cli_words=("$@")
  local directory="$PWD"
  local index token

  for ((index = 1; index + 1 < ${#cli_words[@]}; index++)); do
    token="${cli_words[index]}"
    case "$token" in
      --cwd)
        directory="${cli_words[index + 1]}"
        ((index += 1))
        ;;
      --cwd=*) directory="${token#*=}" ;;
    esac
  done

  (cd -- "$directory" 2>/dev/null && pwd -P) || printf '%s' "$PWD"
}

preview_bun_completion() {
  local runtime="${1:-}"
  local group
  group="$(normalize_group "${2:-}")"
  local word="${3:-}"
  local realpath="${4:-}"
  shift 4
  local -a cli_words=("$@")
  local -a positionals=()
  local directory root token
  local index skip_next=0

  [[ "$runtime" == bun ]] || return 0
  if [[ -n "$realpath" ]]; then
    preview_path "$realpath"
    return 0
  fi
  directory="$(resolve_bun_project_dir "${cli_words[@]}")"

  for ((index = 1; index + 1 < ${#cli_words[@]}; index++)); do
    token="${cli_words[index]}"
    if ((skip_next)); then
      skip_next=0
      continue
    fi
    case "$token" in
      --cwd)
        skip_next=1
        ;;
      --cwd=*) ;;
      -*) ;;
      *) positionals+=("$token") ;;
    esac
  done

  if [[ "${positionals[0]:-}" == run ]]; then
    root="$(find_node_project_root "$directory")"
    if [[ "$group" == *script* ]] || [[ -z "$group" ]]; then
      preview_node_manifest_matches "$root" script "$word" || true
    fi
    # Never run a project script or node_modules binary merely to preview it.
    # File candidates have already returned through the path preview.
    return 0
  fi

  # Bun also offers package scripts alongside its top-level subcommands.
  if [[ ${#positionals[@]} -eq 0 && "$group" == *script* ]]; then
    root="$(find_node_project_root "$directory")"
    preview_node_manifest_matches "$root" script "$word" || true
    return 0
  fi
  preview_help "$runtime" "$word" "${positionals[@]}"
}
