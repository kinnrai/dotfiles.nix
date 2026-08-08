# shellcheck shell=bash

preview_docker() {
  local kind="${1:-}"
  local word="${2:-}"
  shift 2
  local -a docker_args=("$@")

  [[ -n "$word" && "$word" != -* ]] || return 0
  command -v docker >/dev/null 2>&1 || return 0
  if [[ "$kind" == container && "$word" == *:* ]]; then
    word="${word%%:*}"
  fi
  # Failed inspect calls can still emit []. Ignore absent objects instead of
  # formatting null (or passing it to string functions such as ltrimstr).
  case "$kind" in
    auto)
      run_bounded 2s docker "${docker_args[@]}" inspect "$word" 2>/dev/null |
        jq --color-output '
          .[0] | select(type == "object")
          | if .State? and .Config? then
              {
                Name: (.Name | ltrimstr("/")),
                Image: .Config.Image,
                Status: .State.Status,
                Running: .State.Running,
                StartedAt: .State.StartedAt,
                ExitCode: .State.ExitCode,
                Ports: .NetworkSettings.Ports,
                Mounts: [.Mounts[]? | {Type, Source, Destination, Mode, RW}],
                Networks: (.NetworkSettings.Networks // {})
              }
            elif .RepoTags? or .RootFS? then
              {
                RepoTags,
                RepoDigests,
                Id,
                Created,
                Size,
                Architecture,
                Os,
                Entrypoint: .Config.Entrypoint,
                Cmd: .Config.Cmd,
                WorkingDir: .Config.WorkingDir,
                ExposedPorts: .Config.ExposedPorts,
                Volumes: .Config.Volumes
              }
            else . end
        ' | sed -n '1,500p' || true
      ;;
    container)
      run_bounded 2s docker "${docker_args[@]}" inspect --type container "$word" 2>/dev/null |
        jq --color-output '
          .[0] | select(type == "object") | {
            Name: (.Name | ltrimstr("/")),
            Image: .Config.Image,
            Status: .State.Status,
            Running: .State.Running,
            StartedAt: .State.StartedAt,
            ExitCode: .State.ExitCode,
            Ports: .NetworkSettings.Ports,
            Mounts: [.Mounts[]? | {Type, Source, Destination, Mode, RW}],
            Networks: (.NetworkSettings.Networks // {})
          }
        ' | sed -n '1,500p' || true
      ;;
    image)
      run_bounded 2s docker "${docker_args[@]}" inspect --type image "$word" 2>/dev/null |
        jq --color-output '
          .[0] | select(type == "object") | {
            RepoTags,
            RepoDigests,
            Id,
            Created,
            Size,
            Architecture,
            Os,
            Entrypoint: .Config.Entrypoint,
            Cmd: .Config.Cmd,
            WorkingDir: .Config.WorkingDir,
            ExposedPorts: .Config.ExposedPorts,
            Volumes: .Config.Volumes
          }
        ' | sed -n '1,500p' || true
      ;;
    volume)
      run_bounded 2s docker "${docker_args[@]}" inspect --type volume "$word" 2>/dev/null |
        jq --color-output '.[0] | select(type == "object") | {Name, Driver, Scope, Mountpoint, Labels, Options}' |
        sed -n '1,500p' || true
      ;;
    network)
      run_bounded 2s docker "${docker_args[@]}" inspect --type network "$word" 2>/dev/null |
        jq --color-output '
          .[0] | select(type == "object") | {
            Name,
            Id,
            Created,
            Scope,
            Driver,
            EnableIPv6,
            Internal,
            Attachable,
            Ingress,
            IPAM,
            Containers: ((.Containers // {}) | with_entries(
              .value |= {Name, EndpointID, MacAddress, IPv4Address, IPv6Address}
            ))
          }
        ' | sed -n '1,500p' || true
      ;;
    context)
      run_bounded 2s docker "${docker_args[@]}" context inspect "$word" 2>/dev/null |
        jq --color-output '.[0] | select(type == "object") | {Name, Metadata, Endpoints}' |
        sed -n '1,500p' || true
      ;;
  esac
}

collect_docker_locator_args() {
  local -n docker_locator_ref="$1"
  shift
  local -a input=("$@")
  local index token
  docker_locator_ref=()
  # Docker consumes global flags before the subcommand. Stop there: a later
  # -c can mean run/create's CPU shares, not the root command's context.
  # Never forward operation flags or arguments belonging to a command after --.
  for ((index = 0; index < ${#input[@]}; index++)); do
    token="${input[index]}"
    [[ "$token" == -- ]] && break
    [[ -n "$token" ]] || continue
    [[ "$token" == -* ]] || break
    case "$token" in
      --config | -c | --context | -H | --host | --tlscacert | --tlscert | --tlskey)
        if ((index + 1 < ${#input[@]})); then
          docker_locator_ref+=("$token" "${input[index + 1]}")
          ((index += 1))
        fi
        ;;
      --config=* | --context=* | --host=* | -c?* | -H?* | \
        --tlscacert=* | --tlscert=* | --tlskey=* | \
        --tls | --tls=* | --tlsverify | --tlsverify=*)
        docker_locator_ref+=("$token")
        ;;
      *)
        if docker_option_takes_value "$token"; then
          ((index += 1))
        fi
        ;;
    esac
  done
}

docker_option_takes_value() {
  # Docker's Cobra completion keeps one context at every command depth. Only
  # global options can displace the command path; network connect/disconnect
  # options matter additionally because their two operands have different
  # object types. Other command options do not affect dispatch.
  case "${1:-}" in
    --config | -c | --context | -H | --host | -l | --log-level | \
      --tlscacert | --tlscert | --tlskey | --alias | --driver-opt | --ip | \
      --ip6 | --link | --link-local-ip)
      return 0
      ;;
  esac
  return 1
}

collect_docker_positionals() {
  local target_name="${1:-}"
  shift
  local -n docker_positionals_ref="$target_name"
  local -a input=("$@")
  local index token

  docker_positionals_ref=()
  for ((index = 0; index < ${#input[@]}; index++)); do
    token="${input[index]}"
    [[ -n "$token" ]] || continue
    [[ "$token" == -- ]] && break
    [[ "$token" == --*=* ]] && continue
    if docker_option_takes_value "$token"; then
      ((index += 1))
      continue
    fi
    [[ "$token" == -* ]] && continue
    docker_positionals_ref+=("$token")
  done
}

preview_docker_completion() {
  local word="${2:-}"
  local realpath="${3:-}"
  shift 3
  local -a cli_words=("$@")
  local -a parents=()
  local -a positionals=()
  local -a locator_args=()
  local first second

  if ((${#cli_words[@]} > 2)); then
    parents=("${cli_words[@]:1:${#cli_words[@]}-2}")
  fi
  collect_docker_positionals positionals "${parents[@]}"
  collect_docker_locator_args locator_args "${parents[@]}"

  first="${positionals[0]:-}"
  second="${positionals[1]:-}"
  if [[ -n "$realpath" ]]; then
    preview_path "$realpath"
  elif [[ -z "$first" ]]; then
    preview_help docker "$word"
  elif [[ "$first" =~ ^(container|image|volume|network|context)$ && -z "$second" ]]; then
    preview_help docker "$word" "$first"
  elif [[ "$first" == inspect ]]; then
    preview_docker auto "$word" "${locator_args[@]}"
  elif [[ "$first" =~ ^(create|run)$ ]]; then
    preview_docker image "$word" "${locator_args[@]}"
  elif [[ "$first" == container ]]; then
    if [[ "$second" =~ ^(create|run)$ ]]; then
      preview_docker image "$word" "${locator_args[@]}"
    else
      preview_docker container "$word" "${locator_args[@]}"
    fi
  elif [[ "$first" == image ]]; then
    preview_docker image "$word" "${locator_args[@]}"
  elif [[ "$first" == volume ]]; then
    preview_docker volume "$word" "${locator_args[@]}"
  elif [[ "$first" == network ]]; then
    if [[ "$second" =~ ^(connect|disconnect)$ && ${#positionals[@]} -gt 2 ]]; then
      preview_docker container "$word" "${locator_args[@]}"
    else
      preview_docker network "$word" "${locator_args[@]}"
    fi
  elif [[ "$first" == context ]]; then
    preview_docker context "$word" "${locator_args[@]}"
  elif [[ "$first" =~ ^(attach|commit|cp|diff|exec|export|kill|logs|pause|port|rename|restart|rm|start|stats|stop|top|unpause|update|wait)$ ]]; then
    preview_docker container "$word" "${locator_args[@]}"
  else
    return 0
  fi
}
