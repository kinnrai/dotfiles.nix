{ ... }:

{
  programs.bat = {
    enable = true;

    config = {
      theme-light = "Catppuccin Latte";
      theme-dark = "Catppuccin Macchiato";
    };
  };

  home.sessionVariables.MANPAGER = "bat --plain --language=man";
}
