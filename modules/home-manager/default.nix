{ inputs, primaryUser, userHome, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs primaryUser userHome; };
    users.${primaryUser} = ./home.nix;
  };
}
