{
  lib,
  pkgs,
  ...
}:

let
  initOrder = import ../init-order.nix { inherit lib; };
  previewPlugin = import ./preview { inherit pkgs; };
in
{
  # fzf-tab must load after compinit and before plugins that wrap ZLE widgets,
  # such as zsh-autosuggestions and syntax highlighting.
  programs.zsh.initContent = initOrder.fzfTab ''
    if () {
      ${builtins.readFile ./runtime-dir.zsh}
    }; then
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      source ${previewPlugin}/share/zsh/plugins/fzf-tab-preview/fzf-tab-preview.plugin.zsh
    else
      print -u2 -- 'fzf-tab: cannot prepare a private temporary directory; using native completion'
    fi

    # FZF_DEFAULT_OPTS contains popup and height settings intended for the
    # standalone widgets, so keep fzf-tab's inline invocation isolated.
    zstyle ':fzf-tab:*' use-fzf-default-opts no

    # Use a popup inside tmux; ftb-tmux-popup falls back to inline Fzf in
    # Ghostty, Zellij, and other sessions without a tmux pane.
    zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
    zstyle ':fzf-tab:*' popup-min-size 60 12
    zstyle ':fzf-tab:*' popup-smart-tab yes

    zstyle ':fzf-tab:*' switch-group '[' ']'
    zstyle ':fzf-tab:*' show-group full
    zstyle ':fzf-tab:*' single-group color
    zstyle ':fzf-tab:*' fzf-min-height 12
    # Legacy terminal input reports Ctrl-/ as the same byte as Ctrl-_. Bind
    # both names so the preview cycle also works through tmux and basic TTYs.
    zstyle ':fzf-tab:*' fzf-bindings \
      'ctrl-/:change-preview-window(right,55%,border-left|hidden|down,50%,border-top)' \
      'ctrl-_:change-preview-window(right,55%,border-left|hidden|down,50%,border-top)' \
      'ctrl-d:preview-page-down' \
      'ctrl-u:preview-page-up' \
      'ctrl-a:toggle-all'
    zstyle ':fzf-tab:*' fzf-flags \
      '--color=base16' \
      '--preview-window=down,50%,border-top'
  '';
}
