{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }: {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Tomrins-MacBook-Pro
    darwinConfigurations."Tomrins-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      specialArgs = { inherit self; };
      modules = [
        nix-homebrew.darwinModules.nix-homebrew
        ./modules/default.nix
      ];
    };
  };
}
