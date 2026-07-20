{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    paneru = {
      url = "git+https://github.com/karinushka/paneru.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-rafaelswi-menubarusb = {
      url = "github:rafaelswi/homebrew-menubarusb";
      flake = false;
    };
    fish-async-prompt = {
      url = "github:acomagu/fish-async-prompt";
      flake = false;
    };
    fish-magic-enter = {
      url = "github:mattmc3/magic-enter.fish";
      flake = false;
    };
    fish-puffer = {
      url = "github:nickeb96/puffer-fish";
      flake = false;
    };
    ghostty-cursor-shaders = {
      url = "github:sahaj-b/ghostty-cursor-shaders";
      flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, home-manager, ... }:
  let
    primaryUser = "kinnrai";
    userHome = "/Users/${primaryUser}";
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Tomrins-MacBook-Pro
    darwinConfigurations."Tomrins-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      specialArgs = { inherit self inputs primaryUser userHome; };
      modules = [
        home-manager.darwinModules.home-manager
        nix-homebrew.darwinModules.nix-homebrew
        ./modules/default.nix
      ];
    };
  };
}
