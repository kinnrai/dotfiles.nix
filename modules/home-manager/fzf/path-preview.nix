{ pkgs }:

pkgs.writeShellApplication {
  name = "fzf-path-preview";
  runtimeInputs = with pkgs; [
    bat
    chafa
    coreutils
    eza
    file
    gnused
    jq
    libarchive
    libplist
  ];
  text = builtins.readFile ./path-preview.sh;
}
