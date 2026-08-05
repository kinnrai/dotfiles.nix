{
  config,
  inputs,
  pkgs,
  primaryUser,
  ...
}:

let
  brewVersion =
    (builtins.fromJSON (builtins.readFile "${inputs.nix-homebrew}/flake.lock"))
    .nodes.brew-src.original.ref;

  # TODO: Remove the layout patch and completion link farm once upstream fixes
  # both issues. nix-homebrew keeps immutable taps beside a synthetic empty
  # HOMEBREW_REPOSITORY, while Homebrew expects taps and command metadata below
  # that repository. This makes `brew formulae`/`brew casks` empty, and
  # nix-homebrew does not expose Homebrew's own Bash, Fish, or Zsh completions.
  # https://github.com/zhaofengli/nix-homebrew/issues/30
  # https://github.com/zhaofengli/nix-homebrew/issues/77
  brewPackage =
    (pkgs.applyPatches {
      name = "brew-${brewVersion}";
      src = inputs.nix-homebrew.inputs.brew-src;
      patches = [ ./patches/nix-managed-layout.patch ];
    })
    // {
      version = brewVersion;
    };

  brewShellCompletions = pkgs.linkFarm "homebrew-shell-completions" {
    "etc/bash_completion.d/brew" = "${brewPackage}/completions/bash/brew";
    "share/bash-completion/completions/brew" = "${brewPackage}/completions/bash/brew";
    "share/fish/vendor_completions.d/brew.fish" = "${brewPackage}/completions/fish/brew.fish";
    "share/zsh/site-functions/_brew" = "${brewPackage}/completions/zsh/_brew";
  };
in

{
  nix-homebrew = {
    enable = true;
    enableRosetta = false;
    package = brewPackage;
    user = primaryUser;
    autoMigrate = true;
    mutableTaps = false;

    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "rafaelswi/homebrew-menubarusb" = inputs.homebrew-rafaelswi-menubarusb;
    };

    trust = {
      casks = [ "rafaelswi/menubarusb/menubarusb" ];
    };
  };

  homebrew.taps = builtins.attrNames config.nix-homebrew.taps;

  # Expose Homebrew's completions through the standard Nix profile paths.
  environment.systemPackages = [ brewShellCompletions ];
}
