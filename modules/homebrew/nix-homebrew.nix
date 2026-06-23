{ config, inputs, primaryUser, ... }:

{
  nix-homebrew = {
    enable = true;
    enableRosetta = false;
    user = primaryUser;
    autoMigrate = true;
    mutableTaps = false;

    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "rafaelswi/homebrew-menubarusb" = inputs.homebrew-rafaelswi-menubarusb;
    };

    trust = {
      casks = [ "rafaelswi/menubarusb/menubarusb" ];
    };
  };

  homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
}
