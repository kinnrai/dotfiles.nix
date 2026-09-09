{ pkgs }:

if pkgs.stdenv.hostPlatform.isDarwin then
  import ./darwin.nix { inherit pkgs; }
else if pkgs.stdenv.hostPlatform.isLinux then
  import ./linux.nix { inherit pkgs; }
else
  {
    extraPackages = [ ];
    fetchers = [ ];
    keymap = [ ];
    plugins = { };
  }
