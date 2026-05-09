{ self, pkgs, primaryUser, userHome, ... }:

{
  imports = [
    ./fonts.nix
    ./home-manager/default.nix
    ./homebrew/default.nix
    ./homebrew/nix-homebrew.nix
    ./packages.nix
    ./services/apfel.nix
    ./services/colima.nix
    ./services/mihomo.nix
    ./services/sketchybar.nix
  ];

  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Enable alternative shell support in nix-darwin.
  programs.fish = {
    enable = true;
    useBabelfish = true;
  };

  # Allow the nix-darwin fish path to be used as a login shell.
  environment.shells = [ pkgs.fish ];

  users.users.${primaryUser} = {
    name = primaryUser;
    home = userHome;
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
