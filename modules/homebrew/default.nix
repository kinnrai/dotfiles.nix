{ userHome, ... }:

{
  homebrew = {
    enable = true;

    onActivation.cleanup = "zap";
    global.autoUpdate = false;

    caskArgs.appdir = "${userHome}/Applications/Homebrew Apps";

    brews = import ./brews.nix;
    casks = import ./casks.nix;
    masApps = import ./mas-apps.nix;
  };
}
