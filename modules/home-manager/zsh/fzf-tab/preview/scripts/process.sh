# shellcheck shell=bash

preview_process() {
  local pid="${1:-}"

  [[ "$pid" =~ ^[0-9]+$ ]] || return 0
  ps -p "$pid" -o pid,ppid,pcpu,etime,user,args 2>/dev/null |
    render_bat log || true
}

preview_process_name() {
  local name="${1:-}"
  local pid process_name separator=""
  local pids=""

  [[ -n "$name" ]] || return 0
  while read -r pid process_name; do
    # Darwin may return a parenthesized executable path for comm, whereas
    # procps-ng normally returns only the executable name.
    process_name="${process_name#\(}"
    process_name="${process_name%\)}"
    process_name="${process_name##*/}"
    if [[ "$process_name" == "$name" ]]; then
      pids+="${separator}${pid}"
      separator=,
    fi
  done < <(ps -axo pid=,comm= 2>/dev/null || true)
  [[ -n "$pids" ]] || return 0
  ps -p "$pids" -o pid,ppid,pcpu,etime,user,args 2>/dev/null |
    render_bat log || true
}

preview_port() {
  local port="${1:-}"

  [[ "$port" =~ ^[A-Za-z0-9][A-Za-z0-9_.-]*$ ]] || return 0
  run_bounded 2s lsof -nP -i ":$port" 2>/dev/null |
    render_bat log || true
}
