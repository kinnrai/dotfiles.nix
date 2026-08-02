{ pkgs }:

if pkgs.stdenv.isDarwin then
  import ./darwin.nix { inherit pkgs; }
else if pkgs.stdenv.isLinux then
  import ./linux.nix { inherit pkgs; }
else
  {
    extraPackages = [ ];
    fetchers = [ ];
    keymap = [ ];
    plugins = { };
  }
