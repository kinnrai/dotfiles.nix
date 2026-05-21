{ primaryUser, userHome, ... }:

{
  imports = [
    ./aerospace.nix
    ./atuin.nix
    ./eza.nix
    ./fish
    ./fzf.nix
    ./ghostty.nix
    ./git.nix
    ./lazygit.nix
    ./mise.nix
    ./packages.nix
    ./starship.nix
    ./zoxide.nix
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Enable XDG Base Directory support
  #
  # @see https://specifications.freedesktop.org/basedir/latest/
  xdg.enable = true;
  home.preferXdgDirectories = true;
}
