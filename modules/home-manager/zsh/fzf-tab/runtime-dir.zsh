# fzf-tab stores completion snapshots below TMPPREFIX. Its /tmp fallback can
# leave world-readable files after an interrupted picker, so keep the working
# directory inside the platform's private per-user runtime area. The caller
# runs this inside an anonymous function and loads fzf-tab only on success.
local _fzf_tab_tmp_prefix
if [[ -n ${XDG_RUNTIME_DIR:-} && -d $XDG_RUNTIME_DIR && \
  -O $XDG_RUNTIME_DIR ]]; then
  _fzf_tab_tmp_prefix="${XDG_RUNTIME_DIR%/}/zsh"
elif [[ -n ${TMPDIR:-} && -d $TMPDIR && -O $TMPDIR ]]; then
  _fzf_tab_tmp_prefix="${TMPDIR%/}/zsh"
else
  _fzf_tab_tmp_prefix="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/tmp"
fi

local _fzf_tab_tmp_dir="${_fzf_tab_tmp_prefix}-fzf-tab-${USER}"
local -A _fzf_tab_tmp_stat
[[ ! -L $_fzf_tab_tmp_dir ]] || return 1
if [[ ! -e $_fzf_tab_tmp_dir ]]; then
  command mkdir -p -m 700 "$_fzf_tab_tmp_dir" || return 1
fi
[[ ! -L $_fzf_tab_tmp_dir && -d $_fzf_tab_tmp_dir && \
  -O $_fzf_tab_tmp_dir ]] || return 1
zmodload -F zsh/stat b:zstat || return 1
zstat -H _fzf_tab_tmp_stat "$_fzf_tab_tmp_dir" || return 1
if (( (_fzf_tab_tmp_stat[mode] & 8#777) != 8#700 )); then
  command chmod 700 "$_fzf_tab_tmp_dir" || return 1
fi
typeset -g TMPPREFIX="$_fzf_tab_tmp_prefix"
