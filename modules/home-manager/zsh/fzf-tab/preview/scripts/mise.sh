# shellcheck shell=bash

preview_mise_task() {
  local word="${1:-}"
  shift
  local -a global_args=("$@")
  local data

  [[ -n "$word" && "$word" != -* ]] || return 1
  command -v mise >/dev/null 2>&1 || return 1
  data="$(
    run_bounded 2s mise "${global_args[@]}" tasks info --json "$word" \
      2>/dev/null || true
  )"
  [[ -n "$data" ]] || return 1
  jq --color-output '
    {
      name,
      aliases,
      description,
      source,
      depends,
      dir,
      run,
      file,
      sources,
      outputs
    }
  ' <<< "$data"
}

preview_mise_completion() {
  local group word realpath
  group="$(normalize_group "${1:-}")"
  word="${2:-}"
  realpath="${3:-}"
  shift 3
  local -a cli_words=("$@")
  local -a positionals=() global_args=()
  local index token

  if [[ -n "$realpath" ]]; then
    preview_path "$realpath"
    return 0
  fi
  for ((index = 1; index + 1 < ${#cli_words[@]}; index++)); do
    token="${cli_words[index]}"
    case "$token" in
      -C | --cd | -E | --env)
        global_args+=("$token" "${cli_words[index + 1]}")
        ((index += 1))
        ;;
      -C?* | -E?*) global_args+=("$token") ;;
      --cd=* | --env=*) global_args+=("$token") ;;
      -j | --jobs) ((index += 1)) ;;
      -*) ;;
      *) positionals+=("$token") ;;
    esac
  done

  if [[ ${#positionals[@]} -eq 0 || "$group" == *task* || \
    "${positionals[0]:-}" =~ ^(run|r)$ || \
    ( "${positionals[0]:-}" == tasks && \
      "${positionals[1]:-}" =~ ^(info|run|deps)$ ) ]]; then
    preview_mise_task "$word" "${global_args[@]}" && return 0
  fi
  preview_help mise "$word" "${positionals[@]}"
}
