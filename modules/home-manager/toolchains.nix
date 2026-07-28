{ pkgs, ... }:

{
  programs.java = {
    enable = true;
    package = pkgs.jdk25;
  };

  home.packages = with pkgs; [
    cargo
    clippy
    flutter
    go
    lua5_5
    nodejs_24
    pnpm
    python314
    rust-analyzer
    rustc
    rustfmt
    uv
  ];
}
