{ inputs, lib, pkgs, ... }:

let
  shaderRoot = "shaders";

  shaderRepos = {
    ghostty-cursor-shaders = {
      source = inputs.ghostty-cursor-shaders;
    };
  };

  activeShaders = [
    "ghostty-cursor-shaders/cursor_warp.glsl"
    "ghostty-cursor-shaders/ripple_cursor.glsl"
  ];
in
{
  programs.ghostty = {
    enable = true;
    package =
      if pkgs.stdenv.hostPlatform.isDarwin then
        pkgs.ghostty-bin
      else
        pkgs.ghostty;

    enableFishIntegration = true;
    installBatSyntax = true;

    # User config of ghostty
    #
    # @see https://ghostty.org/docs/config/reference
    settings = {
      font-family = "Maple Mono NF CN";
      font-size = 14;
      font-thicken = true;
      adjust-cursor-thickness = "+150%";

      theme = "light:Catppuccin Latte, dark:Catppuccin Macchiato";

      mouse-hide-while-typing = true;

      background-opacity = 0.88;
      # background-blur = "macos-glass-regular";

      notify-on-command-finish = "unfocused";
      notify-on-command-finish-action = "bell,notify";

      window-padding-balance = true;
      window-padding-color = "background";

      window-inherit-working-directory = true;
      tab-inherit-working-directory = true;
      split-inherit-working-directory = true;
      window-inherit-font-size = true;
      window-colorspace = "display-p3";

      focus-follows-mouse = true;
      copy-on-select = "clipboard";

      quick-terminal-position = "top";
      quick-terminal-size = "50%";

      custom-shader = map (shader: "${shaderRoot}/${shader}") activeShaders;
      custom-shader-animation = "always";

      macos-titlebar-style = "tabs";
      macos-window-shadow = false;
      macos-icon = "blueprint";

      keybind = [ "global:alt+backquote=toggle_quick_terminal" ];
    };
  };

  xdg.configFile = lib.mapAttrs' (repoName: repo: {
    name = "ghostty/${shaderRoot}/${repoName}";
    value = {
      source = repo.source;
      recursive = true;
    };
  }) shaderRepos;
}
