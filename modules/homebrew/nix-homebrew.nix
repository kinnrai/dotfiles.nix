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
      "AnInsomniacy/homebrew-motrix-next" = inputs.homebrew-aninsomniacy-motrix-next;
      "antoniorodr/homebrew-memo" = inputs.homebrew-antoniorodr-memo;
      "betterdiscord/homebrew-tap" = inputs.homebrew-betterdiscord-tap;
      "farion1231/homebrew-ccswitch" = inputs.homebrew-farion1231-ccswitch;
      "FelixKratz/homebrew-formulae" = inputs.homebrew-felixkratz-formulae;
      "jundot/homebrew-omlx" = inputs.homebrew-jundot-omlx;
      "lihaoyun6/homebrew-tap" = inputs.homebrew-lihaoyun6-tap;
      "mediosz/homebrew-tap" = inputs.homebrew-mediosz-tap;
      "nikitabobko/homebrew-tap" = inputs.homebrew-nikitabobko-tap;
      "productdevbook/homebrew-tap" = inputs.homebrew-productdevbook-tap;
      "rafaelswi/homebrew-menubarusb" = inputs.homebrew-rafaelswi-menubarusb;
      "steipete/homebrew-tap" = inputs.homebrew-steipete-tap;
    };
  };

  homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
}
