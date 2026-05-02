{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs; [
        act
        apfel-llm
        asciinema
        atuin
        bat
        btop
        chafa
        chezmoi
        chroma
        cocoapods
        colima
        delta
        docker
        docker-buildx
        docker-compose
        docker-credential-helpers
        dust
        eza
        fastfetch
        fzf
        gemini-cli
        git
        git-xet
        gitleaks
        gnupg
        httpie
        kubectl
        kubernetes-helm
        lazydocker
        lazygit
        mas
        mihomo
        mise
        mkvtoolnix-cli
        neovim
        nmap
        opencode
        pandoc
        payload-dumper-go
        pinentry_mac
        rsync
        shellcheck
        sketchybar
        smartmontools
        socat
        starship
        tree
        wget
        xdg-ninja
        yazi
        zoxide
      ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.fish.enable = true;

      # Allow the nix-darwin fish path to be used as a login shell.
      environment.shells = [ pkgs.fish ];

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Tomrins-MacBook-Pro
    darwinConfigurations."Tomrins-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
  };
}
