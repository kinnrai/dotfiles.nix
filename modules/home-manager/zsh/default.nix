{ config, ... }:

{
  imports = [
    ./abbreviations.nix
    ./autosuggestions.nix
    ./completion.nix
    ./core.nix
    ./editing.nix
    ./fzf.nix
    ./fzf-tab.nix
    ./syntax-highlighting.nix
  ];

  programs.zsh = {
    enable = true;

    # Keep generated configuration and mutable shell state out of $HOME.
    dotDir = "${config.xdg.configHome}/zsh";
  };
}
