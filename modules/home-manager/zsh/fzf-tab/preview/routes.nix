{ preview }:

''
  # Keep a universal path fallback, then specialize only contexts whose
  # candidates have useful local or read-only semantics. Avoid starting the
  # helper for option and subcommand groups where fzf-tab has no real path.
  zstyle ':fzf-tab:complete:*:*' fzf-preview \
    'if [[ -n "$realpath" ]]; then ${preview}/bin/fzf-tab-preview path "$realpath"; fi'

  # Git working tree, refs, object history, and local repository metadata.
  zstyle ':fzf-tab:complete:git-(add|restore|diff):argument-rest' fzf-preview \
    '${preview}/bin/fzf-tab-preview git-change "$group" "$word" "$realpath"'
  zstyle ':fzf-tab:complete:git-(branch|switch):argument-1' fzf-preview \
    '${preview}/bin/fzf-tab-preview git-branch "$group" "$word" "$realpath"'
  zstyle ':fzf-tab:complete:git-(checkout|merge):argument-rest' fzf-preview \
    '${preview}/bin/fzf-tab-preview git-branch "$group" "$word" "$realpath"'
  zstyle ':fzf-tab:complete:git-rebase:(argument-rest|options-argument-1|options-option--onto-1)' fzf-preview \
    '${preview}/bin/fzf-tab-preview git-branch "$group" "$word" "$realpath"'
  zstyle ':fzf-tab:complete:git-log:argument-1' fzf-preview \
    '${preview}/bin/fzf-tab-preview git-commit "$group" "$word" "$realpath"'
  zstyle ':fzf-tab:complete:git-(show|reset|tag):argument-rest' fzf-preview \
    '${preview}/bin/fzf-tab-preview git-commit "$group" "$word" "$realpath"'
  # _git separates tag creation, deletion, and verification argument sets.
  zstyle ':fzf-tab:complete:git-tag:(creation-argument-(1|2)|(deletion|verification)-argument-rest)' fzf-preview \
    '${preview}/bin/fzf-tab-preview git-commit "$group" "$word" "$realpath"'
  zstyle ':fzf-tab:complete:git-cherry-pick:(argument-rest|init-argument-rest)' fzf-preview \
    '${preview}/bin/fzf-tab-preview git-commit "$group" "$word" "$realpath"'
  zstyle ':fzf-tab:complete:git-revert:argument-(1|rest)' fzf-preview \
    '${preview}/bin/fzf-tab-preview git-commit "$group" "$word" "$realpath"'
  zstyle ':fzf-tab:complete:git-stash-(apply|drop|pop|show):argument-1' fzf-preview \
    '${preview}/bin/fzf-tab-preview git-stash "$word"'
  # The first operand is a new branch name; the stash is the second operand.
  zstyle ':fzf-tab:complete:git-stash-branch:argument-2' fzf-preview \
    '${preview}/bin/fzf-tab-preview git-stash "$word"'
  zstyle ':fzf-tab:complete:git-(push|pull):argument-1' fzf-preview \
    '${preview}/bin/fzf-tab-preview git-remote "$group" "$word" "$realpath"'
  zstyle ':fzf-tab:complete:git-fetch:argument-rest' fzf-preview \
    '${preview}/bin/fzf-tab-preview git-remote "$group" "$word" "$realpath"'
  zstyle ':fzf-tab:complete:git-remote-(get-url|remove|rename|show):(|argument-(1|rest))' fzf-preview \
    '${preview}/bin/fzf-tab-preview git-remote "$group" "$word" "$realpath"'
  zstyle ':fzf-tab:complete:git-reflog(|-*):argument-(1|rest)' fzf-preview \
    '${preview}/bin/fzf-tab-preview git-reflog "$word"'
  zstyle ':fzf-tab:complete:git-blame:argument-2' fzf-preview \
    '${preview}/bin/fzf-tab-preview git-blame "$group" "$word" "$realpath"'
  zstyle ':fzf-tab:complete:((\\|*/|)git|git-help):argument-1' fzf-preview \
    '${preview}/bin/fzf-tab-preview git-help "$word"'
  zstyle ':fzf-tab:complete:git-check-ignore:argument-rest' fzf-preview \
    '${preview}/bin/fzf-tab-preview git-check-ignore "''${realpath:-$word}"'
  zstyle ':fzf-tab:complete:git-describe:argument-rest' fzf-preview \
    '${preview}/bin/fzf-tab-preview git-describe "$word"'
  zstyle ':fzf-tab:complete:git-worktree-(lock|move|remove|unlock):*' fzf-preview \
    '${preview}/bin/fzf-tab-preview git-worktree "''${realpath:-$word}"'

  # Docker help and local daemon objects. Curated inspect output deliberately
  # excludes container and image environment variables.
  zstyle ':fzf-tab:complete:((\\|*/|)docker|docker-help):argument-1' fzf-preview \
    '${preview}/bin/fzf-tab-preview help docker "$word"'
  zstyle ':fzf-tab:complete:docker-(container|image|volume|network|context):argument-1' fzf-preview \
    '${preview}/bin/fzf-tab-preview help docker "$word" "$words[2]"'
  zstyle ':fzf-tab:complete:docker-inspect:*' fzf-preview \
    '${preview}/bin/fzf-tab-preview docker auto "$word"'
  zstyle ':fzf-tab:complete:docker-(|container-)(attach|commit|cp|diff|exec|export|kill|logs|pause|port|rename|restart|rm|start|stats|stop|top|unpause|update|wait):argument-rest' fzf-preview \
    '${preview}/bin/fzf-tab-preview docker container "$word"'
  zstyle ':fzf-tab:complete:docker-run:argument-1' fzf-preview \
    '${preview}/bin/fzf-tab-preview docker image "$word"'
  zstyle ':fzf-tab:complete:docker-image-(history|inspect|rm|save|tag):argument-rest' fzf-preview \
    '${preview}/bin/fzf-tab-preview docker image "$word"'
  zstyle ':fzf-tab:complete:docker-volume-(inspect|rm):argument-rest' fzf-preview \
    '${preview}/bin/fzf-tab-preview docker volume "$word"'
  zstyle ':fzf-tab:complete:docker-network-(inspect|rm):argument-rest' fzf-preview \
    '${preview}/bin/fzf-tab-preview docker network "$word"'
  zstyle ':fzf-tab:complete:docker-network-(connect|disconnect):argument-1' fzf-preview \
    '${preview}/bin/fzf-tab-preview docker network "$word"'
  zstyle ':fzf-tab:complete:docker-network-(connect|disconnect):argument-2' fzf-preview \
    '${preview}/bin/fzf-tab-preview docker container "$word"'
  zstyle ':fzf-tab:complete:docker-context-(inspect|rm|use|update|export):argument-1' fzf-preview \
    '${preview}/bin/fzf-tab-preview docker context "$word"'
  # The Docker CLI currently ships Cobra-generated completion, which keeps a
  # single context for every depth. Dispatch from the preserved command line.
  zstyle ':fzf-tab:complete:docker:' fzf-preview \
    '${preview}/bin/fzf-tab-preview docker-completion "$group" "$word" "$realpath" "''${(@)words}"'

  # Processes, listening ports, commands, parameters, and local SSH config.
  zstyle ':fzf-tab:complete:(\\|*/|)kill:argument-rest' fzf-preview \
    '${preview}/bin/fzf-tab-preview process "$word"'
  # Zsh exposes ps PID candidates as the coarse `ps:` context on Darwin, but
  # gives each short and long process selector its own context on Linux. Keep
  # the match narrow so file, user, group, and output-property arguments retain
  # their normal path fallback or descriptions.
  zstyle ':fzf-tab:complete:(\\|*/|)ps:(|argument-rest|option-(p|q|s)-1|option--(pid|quick-pid|ppid|sid)-1)' fzf-preview \
    '${preview}/bin/fzf-tab-preview process "$word"'
  zstyle ':fzf-tab:complete:(\\|*/|)(pkill:o-argument-rest|killall:argument-(1|rest))' fzf-preview \
    '${preview}/bin/fzf-tab-preview process-name "$word"'
  zstyle ':fzf-tab:complete:(\\|*/|)lsof:option-i-1' fzf-preview \
    '${preview}/bin/fzf-tab-preview port "$word"'
  zstyle ':fzf-tab:complete:(-command-:|command:option-(v|V)-rest)' fzf-preview \
    'if [[ "$group" == *parameter* ]]; then print -r -- "$word=''${(P)word}"; else ${preview}/bin/fzf-tab-preview command "$group" "$word" "$realpath"; fi'
  zstyle ':fzf-tab:complete:((-parameter-|unset):|(export|typeset|declare|local):argument-rest|vared:argument-1)' fzf-preview \
    'print -r -- "$word=''${(P)word}"'
  zstyle ':fzf-tab:complete:(\\|*/|)(ssh|scp):argument-(1|rest)' fzf-preview \
    '${preview}/bin/fzf-tab-preview ssh-host "$group" "$word" "$realpath"'
  zstyle ':fzf-tab:complete:(\\|*/|)rsync:(|client-)argument-rest' fzf-preview \
    '${preview}/bin/fzf-tab-preview ssh-host "$group" "$word" "$realpath"'
  zstyle ':fzf-tab:complete:(\\|*/|)(man|run-help):*' fzf-preview \
    '${preview}/bin/fzf-tab-preview manual "$group" "$word" "$realpath"'
  zstyle ':fzf-tab:complete:(\\|*/|)(type|whence|where|which):argument-rest' fzf-preview \
    '${preview}/bin/fzf-tab-preview command "$group" "$word" "$realpath"'

  # Subcommand help from the exact CLI visible in the interactive shell.
  zstyle ':fzf-tab:complete:(\\|*/|)nix:' fzf-preview \
    '${preview}/bin/fzf-tab-preview nix-completion "$group" "$word" "$realpath" "''${(@)words}"'
  zstyle ':fzf-tab:complete:(\\|*/|)nix-store:*' fzf-preview \
    '${preview}/bin/fzf-tab-preview nix-path "$word" "$realpath"'
  zstyle ':fzf-tab:complete:gh:' fzf-preview \
    '${preview}/bin/fzf-tab-preview help gh "$word" "''${(@)words[2,-2]}"'
  zstyle ':fzf-tab:complete:(\\|*/|)(uv|cargo|go|chezmoi|direnv|nh|nixpkgs-review|kubectl|helm):argument-1' fzf-preview \
    '${preview}/bin/fzf-tab-preview help "''${words[1]:t}" "$word"'
  # uv and nh generate named contexts for command groups below the root.
  # Match only contexts that still represent subcommands; their leaf argument
  # contexts must retain the universal path fallback.
  zstyle ':fzf-tab:complete:uv-command-(auth|tool|python|pip|workspace|build-backend|cache|self):argument-1' fzf-preview \
    '${preview}/bin/fzf-tab-preview help uv "$word" "''${(@)words[2,-2]}"'
  zstyle ':fzf-tab:complete:uv-auth-command-helper:argument-1' fzf-preview \
    '${preview}/bin/fzf-tab-preview help uv "$word" "''${(@)words[2,-2]}"'
  zstyle ':fzf-tab:complete:nh-command-(os|home|darwin|search|clean):argument-1' fzf-preview \
    '${preview}/bin/fzf-tab-preview help nh "$word" "''${(@)words[2,-2]}"'
  zstyle ':fzf-tab:complete:(cargo|chezmoi|nixpkgs-review):' fzf-preview \
    '${preview}/bin/fzf-tab-preview help "''${words[1]:t}" "$word" "''${(@)words[2,-2]}"'
  zstyle ':fzf-tab:complete:(\\|*/|)(npm|pnpm|pn):*' fzf-preview \
    '${preview}/bin/fzf-tab-preview node-completion "''${words[1]:t}" "$group" "$word" "$realpath" "''${(@)words}"'
  zstyle ':fzf-tab:complete:(\\|*/|)bun:*' fzf-preview \
    '${preview}/bin/fzf-tab-preview bun-completion "''${words[1]:t}" "$group" "$word" "$realpath" "''${(@)words}"'
  # Bun switches to this internal context for scripts, bins, and files.
  zstyle ':fzf-tab:complete:bun-grouped' fzf-preview \
    '${preview}/bin/fzf-tab-preview bun-completion bun "$group" "$word" "$realpath" "''${(@)words}"'
  zstyle ':fzf-tab:complete:(\\|*/|)mise:*' fzf-preview \
    '${preview}/bin/fzf-tab-preview mise-completion "$group" "$word" "$realpath" "''${(@)words}"'
  zstyle ':fzf-tab:complete:(\\|*/|)zellij:argument-1' fzf-preview \
    '${preview}/bin/fzf-tab-preview help zellij "$word"'
  zstyle ':fzf-tab:complete:(\\|*/|)zellij-command-action:argument-1' fzf-preview \
    '${preview}/bin/fzf-tab-preview help zellij-action "$word"'

  # Structured development-tool previews retained from the existing setup.
  zstyle ':fzf-tab:complete:(\\|*/|)jq:argument-rest' fzf-preview \
    '${preview}/bin/fzf-tab-preview json "$realpath"'
  zstyle ':fzf-tab:complete:(\\|*/|)(g|b|d|p|freebsd-|)make:argument-rest' fzf-preview \
    '${preview}/bin/fzf-tab-preview make "$words[1]" "$group" "$word" "$realpath"'
  zstyle ':fzf-tab:complete:(\\|*/|)shellcheck:argument-rest' fzf-preview \
    '${preview}/bin/fzf-tab-preview shellcheck "$realpath"'

  zstyle ':fzf-tab:complete:(\\|*/|)brew:argument-1' fzf-preview \
    '${preview}/bin/fzf-tab-preview help brew "$word"'
  zstyle ':fzf-tab:complete:brew-((|un)install|info|cleanup):(|installed_)(cask|formula)-argument-rest' fzf-preview \
    '${preview}/bin/fzf-tab-preview brew info "$group" "$word"'
  zstyle ':fzf-tab:complete:brew-(list|ls):(|installed_)(cask|formula)-argument-rest' fzf-preview \
    '${preview}/bin/fzf-tab-preview brew list "$group" "$word"'
  zstyle ':fzf-tab:complete:brew-(edit|cat|test):(tap|(|installed_)(cask|formula))-argument-rest' fzf-preview \
    '${preview}/bin/fzf-tab-preview brew source "$group" "$word"'
  zstyle ':fzf-tab:complete:brew-tap-info:tap-argument-rest' fzf-preview \
    '${preview}/bin/fzf-tab-preview brew info "$group" "$word"'

  zstyle ':fzf-tab:complete:tmux:argument-rest' fzf-preview \
    '${preview}/bin/fzf-tab-preview tmux command "$word"'
  zstyle ':fzf-tab:complete:tmux-(show|set)-environment:argument-1' fzf-preview \
    '${preview}/bin/fzf-tab-preview tmux environment "$word" "''${(@)words}"'
  zstyle ':fzf-tab:complete:tmux-set-hook:argument-1' fzf-preview \
    '${preview}/bin/fzf-tab-preview tmux hook "$word" "''${(@)words}"'
  zstyle ':fzf-tab:complete:tmux-(show-options|set-option):argument-rest' fzf-preview \
    '${preview}/bin/fzf-tab-preview tmux option "$word" "''${(@)words}"'
  zstyle ':fzf-tab:complete:tmux-(show-window-options|set-window-option):argument-rest' fzf-preview \
    '${preview}/bin/fzf-tab-preview tmux window-option "$word" "''${(@)words}"'
  zstyle ':fzf-tab:complete:tmux-(show|set)-buffer:option-b-1' fzf-preview \
    '${preview}/bin/fzf-tab-preview tmux buffer "$word" "''${(@)words}"'

  # macOS-only commands are harmless on NixOS because each helper checks that
  # the native command exists before producing output.
  zstyle ':fzf-tab:complete:defaults-(read|read-type|write|rename|delete):argument-1' fzf-preview \
    '${preview}/bin/fzf-tab-preview defaults domain "$group" "$word"'
  zstyle ':fzf-tab:complete:defaults-(read|read-type|write|rename|delete):argument-2' fzf-preview \
    '${preview}/bin/fzf-tab-preview defaults key "$group" "$word" "$words[3]"'
  zstyle ':fzf-tab:complete:defaults:argument-(1|2|rest)' fzf-preview \
    '${preview}/bin/fzf-tab-preview defaults-completion "$group" "$word" "$realpath" "''${(@)words}"'
  # _multi_parts removes completed hierarchy components from word; restore
  # the captured prefixes (e.g. kern.) before querying the selected sysctl.
  zstyle ':fzf-tab:complete:(\\|*/|)sysctl:argument-rest' fzf-preview \
    '${preview}/bin/fzf-tab-preview sysctl "$ctxt[IPREFIX]$ctxt[hpre]$word"'
  zstyle ':fzf-tab:complete:(\\|*/|)networksetup:*' fzf-preview \
    '${preview}/bin/fzf-tab-preview networksetup "$words[2]" "$group" "$word"'
  zstyle ':fzf-tab:complete:(\\|*/|)(plutil|mdls|xattr|stat|du|df|readlink):*' fzf-preview \
    '${preview}/bin/fzf-tab-preview metadata "''${words[1]:t}" "$realpath" "$word"'
  zstyle ':fzf-tab:complete:(\\|*/|)otool:*' fzf-preview \
    '${preview}/bin/fzf-tab-preview otool "$realpath"'
  zstyle ':fzf-tab:complete:(\\|*/|)(codesign|lipo|dwarfdump):*' fzf-preview \
    '${preview}/bin/fzf-tab-preview macho "$realpath"'
  zstyle ':fzf-tab:complete:(\\|*/|)sqlite3:*' fzf-preview \
    '${preview}/bin/fzf-tab-preview sqlite "$realpath"'

  # Remote previews never create candidates. They operate only on candidates
  # returned by kubectl or Helm and forward a small read-only locator allowlist.
  zstyle ':fzf-tab:complete:kubectl-(get|describe|delete|edit|label|annotate|logs|exec|attach|port-forward):argument-rest' fzf-preview \
    '${preview}/bin/fzf-tab-preview kubectl-resource "$word" "''${(@)words}"'
  zstyle ':fzf-tab:complete:kubectl-config-(use-context|delete-context|rename-context):argument-1' fzf-preview \
    '${preview}/bin/fzf-tab-preview kubectl-context "$word"'
  zstyle ':fzf-tab:complete:helm-(status|history|uninstall|rollback):argument-1' fzf-preview \
    '${preview}/bin/fzf-tab-preview helm-release "$word" "''${(@)words}"'
  zstyle ':fzf-tab:complete:helm-get-(all|hooks|manifest|metadata|notes|values):argument-1' fzf-preview \
    '${preview}/bin/fzf-tab-preview helm-release "$word" "''${(@)words}"'
  # Cobra-generated kubectl and Helm completions also retain one context at
  # every command depth, so the helper distinguishes help from object preview.
  zstyle ':fzf-tab:complete:kubectl:' fzf-preview \
    '${preview}/bin/fzf-tab-preview kubectl-completion "$group" "$word" "$realpath" "''${(@)words}"'
  zstyle ':fzf-tab:complete:helm:' fzf-preview \
    '${preview}/bin/fzf-tab-preview helm-completion "$group" "$word" "$realpath" "''${(@)words}"'
''
