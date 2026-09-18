{ self, pkgs, primaryUser, userHome, ... }:

{
  imports = [
    ./fonts.nix
    ./home-manager/default.nix
    ./homebrew/default.nix
    ./homebrew/nix-homebrew.nix
  ];

  nixpkgs.overlays = [
    (import ../overlays/pycharm.nix)
    (import ../overlays/sketchybar)
  ];

  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Enable alternative shell support in nix-darwin.
  programs.bash.completion.enable = true;

  programs.fish = {
    enable = true;
    useBabelfish = true;
  };

  # Home Manager owns the user-level zsh prompt and completion setup.
  programs.zsh = {
    enable = true;
    enableBashCompletion = false;
    enableGlobalCompInit = false;
    promptInit = "";
  };

  # Allow the nix-darwin shell paths to be used as login shells.
  environment.shells = with pkgs; [
    fish
    zsh
  ];

  users.users.${primaryUser} = {
    name = primaryUser;
    home = userHome;
    shell = pkgs.zsh;
  };

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
  system.primaryUser = primaryUser;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;
}
