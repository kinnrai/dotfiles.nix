{ pkgs }:

{
  extraPackages = with pkgs; [
    udisks2
    util-linux
    wl-clipboard
    xclip
    xdg-utils
  ];

  fetchers = [ ];
  keymap = [ ];
  plugins = { };
}
