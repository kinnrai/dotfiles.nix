{ inputs, ... }:

{
  imports = [ inputs.nix-index-database.homeModules.default ];

  programs = {
    nix-index = {
      enable = true;
      enableFishIntegration = true;
    };

    nix-index-database.comma.enable = true;
  };
}
