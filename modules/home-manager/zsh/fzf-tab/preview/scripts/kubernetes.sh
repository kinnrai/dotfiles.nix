# shellcheck shell=bash

collect_locator_args() {
  local kind="${1:-}"
  local target_name="${2:-}"
  shift 2
  local -n locator_ref="$target_name"
  local -a input=("$@")
  local index token

  locator_ref=()
  for ((index = 0; index < ${#input[@]}; index++)); do
    token="${input[index]}"
    [[ "$token" == -- ]] && break
    case "$kind:$token" in
      kubectl:-n | kubectl:--namespace | kubectl:--context | \
        kubectl:--kubeconfig | kubectl:--cluster | kubectl:--user | \
        helm:-n | helm:--namespace | helm:--kube-context | helm:--kubeconfig | \
        kubectl-config:--kubeconfig)
        if ((index + 1 < ${#input[@]})); then
          locator_ref+=("$token" "${input[index + 1]}")
          ((index += 1))
        fi
        ;;
      kubectl:--namespace=* | kubectl:--context=* | kubectl:--kubeconfig=* | \
        kubectl:--cluster=* | kubectl:--user=* | kubectl:--all-namespaces | \
        kubectl:-A | kubectl:-n?* | \
        helm:--namespace=* | helm:--kube-context=* | helm:--kubeconfig=* | \
        kubectl-config:--kubeconfig=*)
        locator_ref+=("$token")
        ;;
      helm:-n?*) locator_ref+=("$token") ;;
    esac
  done
}

kubectl_global_option_takes_value() {
  case "${1:-}" in
    --as | --as-group | --as-uid | --cache-dir | \
      --certificate-authority | --client-certificate | --client-key | \
      --cluster | --context | --kubeconfig | --log-flush-frequency | \
      -n | --namespace | --password | --profile | --profile-output | \
      --request-timeout | -s | --server | --tls-server-name | --token | \
      --user | --username | -v | --v | --vmodule)
      return 0
      ;;
  esac
  return 1
}

kubectl_command_option_takes_value() {
  local command_name="${1:-}"
  local option="${2:-}"

  case "$command_name:$option" in
    get:--chunk-size | get:--field-selector | get:-f | get:--filename | \
      get:-k | get:--kustomize | get:-L | get:--label-columns | get:-o | \
      get:--output | get:--raw | get:-l | get:--selector | get:--sort-by | \
      get:--subresource | get:--template | \
      describe:--chunk-size | describe:-f | describe:--filename | \
      describe:-k | describe:--kustomize | describe:-l | describe:--selector | \
      delete:--cascade | delete:--dry-run | delete:--field-selector | \
      delete:-f | delete:--filename | delete:-k | delete:--kustomize | \
      delete:--grace-period | delete:-o | delete:--output | delete:--raw | \
      delete:-l | delete:--selector | delete:--timeout | \
      edit:--field-manager | edit:-f | edit:--filename | edit:-k | \
      edit:--kustomize | edit:-o | edit:--output | edit:--subresource | \
      edit:--template | edit:--validate | \
      label:--dry-run | label:--field-manager | label:--field-selector | \
      label:-f | label:--filename | label:-k | label:--kustomize | \
      label:-o | label:--output | label:--resource-version | label:-l | \
      label:--selector | label:--template | \
      annotate:--dry-run | annotate:--field-manager | \
      annotate:--field-selector | annotate:-f | annotate:--filename | \
      annotate:-k | annotate:--kustomize | annotate:-o | annotate:--output | \
      annotate:--resource-version | annotate:-l | annotate:--selector | \
      annotate:--template | \
      logs:-c | logs:--container | logs:--limit-bytes | \
      logs:--max-log-requests | logs:--pod-running-timeout | logs:-l | \
      logs:--selector | logs:--since | logs:--since-time | logs:--tail | \
      exec:-c | exec:--container | exec:-f | exec:--filename | \
      exec:--pod-running-timeout | \
      attach:-c | attach:--container | attach:--pod-running-timeout | \
      port-forward:--address | port-forward:--pod-running-timeout)
      return 0
      ;;
  esac
  return 1
}

collect_kubectl_positionals() {
  local target_name="${1:-}"
  shift
  local -n kubectl_positionals_ref="$target_name"
  local -a input=("$@")
  local index token command_name=""

  # Cobra preserves the command line but not typed option metadata in its
  # completion context. Skip explicit value-taking flags so selectors and
  # output arguments cannot be mistaken for a resource type.
  kubectl_positionals_ref=()
  for ((index = 1; index + 1 < ${#input[@]}; index++)); do
    token="${input[index]}"
    [[ -n "$token" ]] || continue
    [[ "$token" == -- ]] && break
    [[ "$token" == --*=* ]] && continue
    if kubectl_global_option_takes_value "$token" || \
      kubectl_command_option_takes_value "$command_name" "$token"; then
      ((index += 1))
      continue
    fi
    [[ "$token" == -* ]] && continue
    kubectl_positionals_ref+=("$token")
    [[ -n "$command_name" ]] || command_name="$token"
  done
}

kubectl_resource_from_words() {
  local word="${1:-}"
  shift
  local -a positional=()
  local command_name resource_type

  collect_kubectl_positionals positional "$@"

  command_name="${positional[0]:-}"
  resource_type="${positional[1]:-}"
  if [[ "$word" == */* ]]; then
    printf '%s' "$word"
  elif [[ "$command_name" =~ ^(logs|exec|attach|port-forward)$ ]]; then
    printf 'pod/%s' "$word"
  elif [[ -n "$resource_type" && "$resource_type" != "$word" ]]; then
    printf '%s/%s' "$resource_type" "$word"
  else
    printf '%s' "$word"
  fi
}

preview_kubectl_resource() {
  local word="${1:-}"
  shift
  local resource
  local -a positionals=()
  local -a locator_args=()
  local -a cli_words=("$@")

  [[ -n "$word" && "$word" != -* ]] || return 0
  command -v kubectl >/dev/null 2>&1 || return 0
  collect_kubectl_positionals positionals "${cli_words[@]}"
  case "${positionals[0]:-}" in
    logs | exec | attach | port-forward)
      ((${#positionals[@]} == 1)) || return 0
      ;;
    get | describe | delete | edit | label | annotate)
      [[ -n "${positionals[1]:-}" ]] || return 0
      ;;
    *) return 0 ;;
  esac
  collect_locator_args kubectl locator_args "${cli_words[@]}"
  resource="$(kubectl_resource_from_words "$word" "${cli_words[@]}")"
  [[ -n "$resource" ]] || return 0
  run_bounded 3s kubectl get "$resource" "${locator_args[@]}" \
    --output=json --request-timeout=3s 2>/dev/null |
    jq --color-output '
      def redact:
        if type == "object" then
          if .kind? == "Secret" then
            # kubectl apply can duplicate Secret data inside this annotation.
            del(.data, .stringData,
                .metadata.annotations."kubectl.kubernetes.io/last-applied-configuration")
            | .data = "<redacted>"
          else
            with_entries(.value |= redact)
          end
        elif type == "array" then map(redact)
        else .
        end;
      redact | walk(if type == "object" then del(.managedFields) else . end)
    ' | sed -n '1,500p' || true
}

preview_kubectl_context() {
  local word="${1:-}"
  shift
  local -a locator_args=()

  [[ -n "$word" && "$word" != -* ]] || return 0
  command -v kubectl >/dev/null 2>&1 || return 0
  # Read the same config as completion; the highlighted context, not a prior
  # --context flag, selects the entry. No cluster connection is needed.
  collect_locator_args kubectl-config locator_args "$@"
  run_bounded 3s kubectl "${locator_args[@]}" config view --minify --context="$word" --output=json \
    2>/dev/null |
    jq --color-output '
      walk(
        if type == "object" then
          del(
            .token,
            .password,
            ."client-key-data",
            ."client-certificate-data",
            ."auth-provider",
            .exec
          )
        else . end
      )
    ' | sed -n '1,500p' || true
}

preview_helm_release() {
  local word="${1:-}"
  shift
  local -a locator_args=()

  [[ -n "$word" && "$word" != -* ]] || return 0
  command -v helm >/dev/null 2>&1 || return 0
  collect_locator_args helm locator_args "$@"
  run_bounded 3s helm status "$word" "${locator_args[@]}" --color always \
    2>/dev/null | sed -n '1,500p' || true
}

preview_kubectl_completion() {
  local word="${2:-}"
  local realpath="${3:-}"
  shift 3
  local -a cli_words=("$@")
  local -a positionals=()
  local first second

  collect_kubectl_positionals positionals "${cli_words[@]}"
  first="${positionals[0]:-}"
  second="${positionals[1]:-}"

  if [[ -n "$realpath" ]]; then
    preview_path "$realpath"
  elif [[ -z "$first" ]]; then
    preview_help kubectl "$word"
  elif [[ "$first" == config && "$second" =~ ^(use-context|delete-context|rename-context)$ ]]; then
    preview_kubectl_context "$word" "${cli_words[@]}"
  elif [[ "$first" == config && -z "$second" ]]; then
    preview_help kubectl "$word" config
  elif [[ "$first" =~ ^(logs|exec|attach|port-forward)$ ]] && \
    ((${#positionals[@]} == 1)); then
    preview_kubectl_resource "$word" "${cli_words[@]}"
  elif [[ "$first" =~ ^(get|describe|delete|edit|label|annotate)$ && -n "$second" ]]; then
    preview_kubectl_resource "$word" "${cli_words[@]}"
  else
    return 0
  fi
}

helm_option_takes_value() {
  case "${1:-}" in
    --burst-limit | --kube-apiserver | --kube-as-group | --kube-as-user | \
      --kube-ca-file | --kube-context | \
      --kube-tls-server-name | --kube-token | --kubeconfig | -n | \
      --namespace | --qps | --registry-config | --repository-cache | \
      --repository-config | --cascade | --description | --history-max | \
      --kube-version | --max | --output | -o | --post-renderer | \
      --post-renderer-args | --revision | --set | --set-file | --set-json | \
      --set-literal | --set-string | --timeout)
      return 0
      ;;
  esac
  return 1
}

collect_helm_positionals() {
  local target_name="${1:-}"
  shift
  local -n helm_positionals_ref="$target_name"
  local -a input=("$@")
  local index token

  helm_positionals_ref=()
  for ((index = 1; index + 1 < ${#input[@]}; index++)); do
    token="${input[index]}"
    [[ -n "$token" ]] || continue
    [[ "$token" == -- ]] && break
    [[ "$token" == --*=* ]] && continue
    if helm_option_takes_value "$token"; then
      ((index += 1))
      continue
    fi
    [[ "$token" == -* ]] && continue
    helm_positionals_ref+=("$token")
  done
}

preview_helm_completion() {
  local word="${2:-}"
  local realpath="${3:-}"
  shift 3
  local -a cli_words=("$@")
  local -a positionals=()
  local first second

  collect_helm_positionals positionals "${cli_words[@]}"
  first="${positionals[0]:-}"
  second="${positionals[1]:-}"

  if [[ -n "$realpath" ]]; then
    preview_path "$realpath"
  elif [[ -z "$first" ]]; then
    preview_help helm "$word"
  elif [[ "$first" =~ ^(status|history|uninstall|rollback)$ ]] && \
    ((${#positionals[@]} == 1)); then
    preview_helm_release "$word" "${cli_words[@]}"
  elif [[ "$first" == get && \
    "$second" =~ ^(all|hooks|manifest|metadata|notes|values)$ ]] && \
    ((${#positionals[@]} == 2)); then
    preview_helm_release "$word" "${cli_words[@]}"
  elif [[ "$first" == get && -z "$second" ]]; then
    preview_help helm "$word" get
  else
    return 0
  fi
}
