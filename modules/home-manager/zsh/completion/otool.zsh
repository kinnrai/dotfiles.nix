# TODO: Remove this patch when Zsh's upstream _otool preserves curcontext.
# It currently initializes curcontext from the unrelated, normally empty
# $context parameter, so fzf-tab cannot select command-specific preview styles.
# https://github.com/zsh-users/zsh/blob/master/Completion/Darwin/Command/_otool
if (( ${+functions[_otool]} )); then
  autoload -Uz +X _otool
  if [[ $functions[_otool] == *'curcontext=$context'* ]]; then
    functions[_otool]=${functions[_otool]/curcontext=\$context/curcontext=\$curcontext}
  fi
fi
