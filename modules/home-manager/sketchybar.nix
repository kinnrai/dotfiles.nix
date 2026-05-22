{ pkgs, ... }:

{
  programs.sketchybar = {
    enable = true;
    configType = "lua";

    # Keep ~/.config/sketchybar unmanaged for now; Home Manager only manages
    # the package wrapper and the launchd agent.
    sbarLuaPackage = pkgs.sbarlua;

    # The current Lua config shells out to AeroSpace.
    extraPackages = [ pkgs.aerospace ];
  };
}
