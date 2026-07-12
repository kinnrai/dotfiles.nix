{ inputs, pkgs, ... }:

{
  programs.sketchybar = {
    enable = true;
    configType = "lua";

    # Keep ~/.config/sketchybar unmanaged for now; Home Manager only manages
    # the package wrapper and the launchd agent.
    sbarLuaPackage = pkgs.sbarlua;

    # The local Lua config queries Paneru virtual workspaces.
    extraPackages = [
      pkgs.aerospace
      inputs.paneru.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
