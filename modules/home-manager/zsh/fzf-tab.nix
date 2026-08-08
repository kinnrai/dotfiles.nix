{
  lib,
  pkgs,
  ...
}:

let
  initOrder = import ./init-order.nix { inherit lib; };
in
{
  # fzf-tab must load after compinit and before plugins that wrap ZLE widgets,
  # such as zsh-autosuggestions and syntax highlighting.
  programs.zsh.initContent = initOrder.fzfTab ''
    source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

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
    zstyle ':fzf-tab:*' fzf-bindings 'ctrl-a:toggle-all'
    zstyle ':fzf-tab:*' fzf-flags '--color=base16'
  '';
}
