# Zsh's upstream _ssh_hosts returns as soon as _hosts finds an /etc/hosts or
# known_hosts entry, so it can skip the later ~/.ssh/config parser entirely.
# Keep its parser, but merge both sources before returning from completion.
_ssh_hosts() {
  setopt local_options extended_glob

  local -aU config_hosts
  local -a lines match_args
  local config key line host
  local expl
  local ret=1
  integer ind idx=1

  if [[ $IPREFIX == *@ ]]; then
    _combination -s '[:@]' my-accounts users-hosts \
      "users=${IPREFIX/@}" hosts "$@" && ret=0
  else
    _combination -s '[:@]' my-accounts users-hosts \
      ${opt_args[-l]:+"users=${opt_args[-l]:q}"} hosts "$@" && ret=0
  fi

  if (( ind = ${words[(I)-F]} )); then
    config=${~words[ind+1]} 2>/dev/null
  else
    config="$HOME/.ssh/config"
  fi
  [[ -r $config ]] || return ret

  lines=("${(@f)$(<"$config")}") 2>/dev/null
  while (( idx <= $#lines )); do
    IFS=$'=\t ' read -r key line <<<"${lines[idx]}"
    if [[ $key == ((#i)match) ]]; then
      match_args=( ${(Z.C.)line} )
      while (( $#match_args >= 2 )); do
        if [[ ${match_args[1]} == (#i)(canonical|final|(|original)host) ]]; then
          key=Host
          line="${match_args[2]//,/ }"
          break
        fi
        shift 2 match_args
      done
    fi
    case $key in
      ((#i)include)
        lines[idx]=( "${(@f)$(cd "$HOME/.ssh"; cat ${(Z.C.)~line} 2>/dev/null)}" )
        ;;
      ((#i)host(|name))
        for host in ${(Z.C.)line}; do
          [[ $host != *[*?%]* ]] && config_hosts+=( "$host" )
        done
        ;&
      (*)
        (( ++idx ))
        ;;
    esac
  done

  if (( $#config_hosts )); then
    _wanted hosts expl 'remote host name' \
      compadd -M 'm:{a-zA-Z}={A-Za-z} r:|.=* r:|=*' "$@" $config_hosts && ret=0
  fi
  return ret
}
