# shellcheck shell=bash

mode="${1:-}"
[[ $# -gt 0 ]] && shift
{
  case "$mode" in
    path) preview_path "${1:-}" ;;
    git-change) preview_git_change "${1:-}" "${2:-}" "${3:-}" ;;
    git-branch) preview_git_branch "${1:-}" "${2:-}" "${3:-}" ;;
    git-commit) preview_git_commit "${1:-}" "${2:-}" "${3:-}" ;;
    git-stash) preview_git_stash "${1:-}" ;;
    git-remote) preview_git_remote "${1:-}" "${2:-}" "${3:-}" ;;
    git-reflog) preview_git_reflog "${1:-}" ;;
    git-blame) preview_git_blame "${1:-}" "${2:-}" "${3:-}" ;;
    git-help) preview_git_help "${1:-}" ;;
    git-check-ignore) preview_git_check_ignore "${1:-}" ;;
    git-describe) preview_git_describe "${1:-}" ;;
    git-worktree) preview_git_worktree "${1:-}" ;;
    process) preview_process "${1:-}" ;;
    process-name) preview_process_name "${1:-}" ;;
    port) preview_port "${1:-}" ;;
    help) preview_help "$@" ;;
    command) preview_command "${1:-}" "${2:-}" "${3:-}" ;;
    manual) preview_manual "${1:-}" "${2:-}" "${3:-}" ;;
    node-completion) preview_node_completion "$@" ;;
    bun-completion) preview_bun_completion "$@" ;;
    mise-completion) preview_mise_completion "$@" ;;
    shellcheck) preview_shellcheck "${1:-}" ;;
    nix-completion) preview_nix_completion "$@" ;;
    nix-path) preview_nix_path "${1:-}" "${2:-}" ;;
    docker) preview_docker "${1:-}" "${2:-}" ;;
    docker-completion) preview_docker_completion "$@" ;;
    ssh-host) preview_ssh_host "${1:-}" "${2:-}" "${3:-}" ;;
    defaults) preview_defaults "${1:-}" "${2:-}" "${3:-}" "${4:-}" ;;
    defaults-completion) preview_defaults_completion "$@" ;;
    sysctl) preview_sysctl "${1:-}" ;;
    networksetup) preview_networksetup "${1:-}" "${2:-}" "${3:-}" ;;
    metadata) preview_metadata "${1:-}" "${2:-}" "${3:-}" ;;
    otool) preview_otool "${1:-}" ;;
    macho) preview_macho "${1:-}" || preview_path "${1:-}" ;;
    sqlite) preview_sqlite "${1:-}" || preview_path "${1:-}" ;;
    kubectl-resource) preview_kubectl_resource "$@" ;;
    kubectl-context) preview_kubectl_context "${1:-}" "${@:2}" ;;
    kubectl-completion) preview_kubectl_completion "$@" ;;
    helm-release) preview_helm_release "$@" ;;
    helm-completion) preview_helm_completion "$@" ;;
    json) preview_json "${1:-}" ;;
    make) preview_make "$@" ;;
    brew) preview_brew "$@" ;;
    tmux) preview_tmux "$@" ;;
  esac
} | sed -n '1,500p;500q' || true
