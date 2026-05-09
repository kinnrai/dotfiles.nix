{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-aninsomniacy-motrix-next = {
      url = "github:AnInsomniacy/homebrew-motrix-next";
      flake = false;
    };
    homebrew-antoniorodr-memo = {
      url = "github:antoniorodr/homebrew-memo";
      flake = false;
    };
    homebrew-betterdiscord-tap = {
      url = "github:betterdiscord/homebrew-tap";
      flake = false;
    };
    homebrew-farion1231-ccswitch = {
      url = "github:farion1231/homebrew-ccswitch";
      flake = false;
    };
    homebrew-felixkratz-formulae = {
      url = "github:FelixKratz/homebrew-formulae";
      flake = false;
    };
    homebrew-jundot-omlx = {
      url = "github:jundot/omlx";
      flake = false;
    };
    homebrew-lihaoyun6-tap = {
      url = "github:lihaoyun6/homebrew-tap";
      flake = false;
    };
    homebrew-mediosz-tap = {
      url = "github:mediosz/homebrew-tap";
      flake = false;
    };
    homebrew-nikitabobko-tap = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };
    homebrew-productdevbook-tap = {
      url = "github:productdevbook/homebrew-tap";
      flake = false;
    };
    homebrew-rafaelswi-menubarusb = {
      url = "github:rafaelswi/homebrew-menubarusb";
      flake = false;
    };
    homebrew-steipete-tap = {
      url = "github:steipete/homebrew-tap";
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
