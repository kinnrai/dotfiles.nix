{ pkgs, ... }:

{
  home.packages = with pkgs; [
    neovim
    clang
    curl
    fd
    ripgrep
    tree-sitter
    unzip
  ];
}
