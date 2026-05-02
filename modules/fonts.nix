{ pkgs, ... }:

{
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.maple-mono.NF-CN
  ];
}
