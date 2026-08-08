{
  config,
  lib,
  pkgs,
  ...
}:

let
  completionCache = "${config.xdg.cacheHome}/zsh/completion";
  initOrder = import ./init-order.nix { inherit lib; };
in
{
  # Home Manager exposes package completions through the user profile, whose
  # site-functions directory is added to fpath before compinit runs.
  home.packages = [ pkgs.zsh-completions ];

  programs.zsh = {
    completionInit = ''
      autoload -Uz compinit
      mkdir -p "${completionCache}"
      compinit -d "${config.xdg.cacheHome}/zsh/zcompdump"
    '';

    initContent = lib.mkMerge [
      (initOrder.completionStyles ''
        zstyle ':completion:*' group-name ""
        zstyle ':completion:*:descriptions' format '[%d]'
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
        zstyle ':completion:*' menu no
        zstyle ':completion:*' use-cache true
        zstyle ':completion:*' cache-path "${completionCache}"
      '')

      # Refresh completions after tools such as direnv and nix develop update
      # XDG_DATA_DIRS or fpath. Keep normal compinit security checks enabled.
      (initOrder.completionSync ''
        zstyle ':completion-sync:xdg' enabled true
        zstyle ':completion-sync:path' enabled false
        zstyle ':completion-sync:compinit:optimizations:fast-add' enabled false
        zstyle ':completion-sync:compinit:optimizations:no-caching' enabled false
        zstyle ':completion-sync:compinit:compat:zsh-autocomplete' enabled false
        source ${pkgs.zsh-completion-sync}/share/zsh-completion-sync/zsh-completion-sync.plugin.zsh
      '')
    ];
  };
}
