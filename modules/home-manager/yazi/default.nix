{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  platform = import ./platforms { inherit pkgs; };

  keymap = import ./keymap.nix ++ platform.keymap;
  plugins = import ./plugins.nix { inherit lib pkgs; } // platform.plugins;

  commonSettings = import ./settings.nix;
  settings = commonSettings // {
    plugin = commonSettings.plugin // {
      prepend_fetchers = commonSettings.plugin.prepend_fetchers ++ platform.fetchers;
    };
  };
in
{
  programs.yazi = {
    enable = true;
    package = pkgs.yazi.override { _7zz = pkgs._7zz-rar; };

    enableFishIntegration = true;
    shellWrapperName = "y";

    extraPackages = (with pkgs; [
      eza
      gh
      git
      glow
      lazygit
      mediainfo
      ouch
    ]) ++ platform.extraPackages;

    inherit plugins settings;
    initLua = builtins.readFile ./lua/session.lua;
    keymap.mgr.prepend_keymap = keymap;

    theme.flavor = {
      light = "catppuccin-latte";
      dark = "catppuccin-macchiato";
    };

    flavors = {
      catppuccin-latte = "${inputs.yazi-flavors}/catppuccin-latte.yazi";
      catppuccin-macchiato = "${inputs.yazi-flavors}/catppuccin-macchiato.yazi";
    };
  };
}
