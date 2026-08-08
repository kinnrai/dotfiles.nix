# shellcheck shell=bash

preview_git_diff() {
  local candidate="${1:-}"
  local staged="${2:-false}"

  [[ -n "$candidate" ]] || return 0
  if [[ "$staged" == true ]]; then
    git --no-pager diff --cached --color=always -- "$candidate" 2>/dev/null |
      render_delta || true
  else
    git --no-pager diff --color=always -- "$candidate" 2>/dev/null |
      render_delta || true
  fi
}

preview_git_revision_diff() {
  local word="${1:-}"

  [[ -n "$word" ]] || return 0
  git rev-parse --verify --quiet "$word^{object}" >/dev/null 2>&1 || return 0
  git --no-pager diff --color=always "$word" 2>/dev/null |
    render_delta || true
}

preview_git_change() {
  local group word realpath candidate
  group="$(normalize_group "${1:-}")"
  word="${2:-}"
  realpath="${3:-}"
  candidate="${realpath:-$word}"

  case "$group" in
    *ignored* | *untracked* | *tree\ file*) preview_path "$candidate" ;;
    *cached* | *staged* | *index\ file*) preview_git_diff "$candidate" true ;;
    *head* | *commit* | *tag* | *reference*) preview_git_revision_diff "$word" ;;
    *) preview_git_diff "$candidate" ;;
  esac
}

preview_git_branch() {
  local group word realpath candidate
  group="$(normalize_group "${1:-}")"
  word="${2:-}"
  realpath="${3:-}"
  candidate="${realpath:-$word}"

  case "$group" in
    *file*) preview_git_diff "$candidate" ;;
    *)
      [[ -n "$word" ]] || return 0
      git rev-parse --verify --quiet "$word^{commit}" >/dev/null 2>&1 || return 0
      git --no-pager log \
        --color=always \
        --decorate \
        --oneline \
        --max-count=40 \
        "$word" \
        -- 2>/dev/null || true
      ;;
  esac
}

preview_git_commit() {
  local group word realpath candidate
  group="$(normalize_group "${1:-}")"
  word="${2:-}"
  realpath="${3:-}"
  candidate="${realpath:-$word}"

  case "$group" in
    *file*) preview_path "$candidate" ;;
    *)
      [[ -n "$word" ]] || return 0
      git rev-parse --verify --quiet "$word^{object}" >/dev/null 2>&1 || return 0
      git --no-pager show --color=always "$word" -- 2>/dev/null |
        render_delta || true
      ;;
  esac
}

preview_git_stash() {
  local word="${1:-}"

  [[ -n "$word" ]] || return 0
  git rev-parse --verify --quiet "$word^{commit}" >/dev/null 2>&1 || return 0
  git --no-pager stash show --patch --color=always "$word" 2>/dev/null |
    render_delta || true
}

preview_git_remote() {
  local group word realpath
  group="$(normalize_group "${1:-}")"
  word="${2:-}"
  realpath="${3:-}"
  local fetch_urls push_urls

  [[ -n "$word" ]] || return 0
  case "$group" in
    *host*)
      preview_ssh_host "$group" "$word" "$realpath"
      return 0
      ;;
    *local\ repository* | *file*)
      preview_path "${realpath:-$word}"
      return 0
      ;;
  esac
  fetch_urls="$(git remote get-url --all "$word" 2>/dev/null)" || return 0
  push_urls="$(git remote get-url --push --all "$word" 2>/dev/null || true)"
  printf '[Fetch URLs]\n%s\n' "$fetch_urls"
  [[ -n "$push_urls" ]] && printf '\n[Push URLs]\n%s\n' "$push_urls"
  printf '\n[Tracking refs]\n'
  git for-each-ref \
    --color=always \
    --format='%(color:yellow)%(refname:short)%(color:reset) %(objectname:short) %(subject)' \
    "refs/remotes/$word/" 2>/dev/null | sed -n '1,500p' || true
}

preview_git_reflog() {
  local word="${1:-}"
  local -a args=(--color=always --date=relative --max-count=80)

  if [[ -n "$word" ]] && git rev-parse --verify --quiet "$word" >/dev/null 2>&1; then
    args+=("$word")
  fi
  git --no-pager reflog show "${args[@]}" 2>/dev/null || true
}

preview_git_blame() {
  local group word realpath candidate
  group="$(normalize_group "${1:-}")"
  word="${2:-}"
  realpath="${3:-}"
  candidate="${realpath:-$word}"

  if [[ "$group" == *file* ]]; then
    [[ -n "$candidate" && -f "$candidate" ]] || return 0
    git --no-pager blame --color-lines -- "$candidate" 2>/dev/null |
      sed -n '1,500p' || true
  else
    preview_git_commit "$group" "$word" "$realpath"
  fi
}

preview_git_help() {
  local word="${1:-}"
  local width="${FZF_PREVIEW_COLUMNS:-80}"

  [[ -n "$word" && "$word" != -* ]] || return 0
  [[ "$width" =~ ^[0-9]+$ ]] || width=80
  GIT_PAGER=cat GROFF_NO_SGR=1 MANPAGER=cat MANWIDTH="$width" \
    run_bounded 2s git help "$word" 2>/dev/null |
    col -bx | render_limited man || true
}

preview_git_check_ignore() {
  local candidate="${1:-}"
  local output

  [[ -n "$candidate" ]] || return 0
  output="$(git check-ignore --verbose -- "$candidate" 2>/dev/null || true)"
  if [[ -n "$output" ]]; then
    printf '%s\n' "$output" | render_limited gitignore
  else
    preview_path "$candidate"
  fi
}

preview_git_describe() {
  local word="${1:-}"

  [[ -n "$word" ]] || return 0
  git rev-parse --verify --quiet "$word^{commit}" >/dev/null 2>&1 || return 0
  printf '[Description]\n'
  git describe --always --tags "$word" 2>/dev/null || true
  printf '\n[Commit]\n'
  git --no-pager log --color=always --decorate --oneline --max-count=1 \
    "$word" -- 2>/dev/null || true
}

preview_git_worktree() {
  local candidate="${1:-}"
  local candidate_real line path="" path_real record="" matched=""

  [[ -n "$candidate" ]] || return 0
  candidate="${candidate%/}"
  candidate_real="$(realpath -- "$candidate" 2>/dev/null || printf '%s' "$candidate")"
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == worktree\ * ]]; then
      path="${line#worktree }"
      record="$line"
    elif [[ -z "$line" ]]; then
      path_real="$(realpath -- "$path" 2>/dev/null || printf '%s' "$path")"
      if [[ "${path_real%/}" == "${candidate_real%/}" ]]; then
        matched="$record"
        break
      fi
      path=""
      record=""
    else
      record+=$'\n'"$line"
    fi
  done < <(git worktree list --porcelain 2>/dev/null; printf '\n')

  if [[ -n "$matched" && -n "$path" ]]; then
    printf '[Worktree]\n%s\n' "$matched"
    printf '\n[Status]\n'
    git -C "$path" --no-pager status --short --branch 2>/dev/null || true
  else
    preview_path "$candidate"
  fi
}
