{ ... }:

{
  programs.zellij = {
    enable = true;

    settings = {
      default_mode = "locked";
      theme = "catppuccin-latte";
      theme_light = "catppuccin-latte";
      theme_dark = "catppuccin-macchiato";
    };

    extraConfig = builtins.readFile ./config.kdl;
  };
}
