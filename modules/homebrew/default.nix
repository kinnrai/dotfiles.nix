{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      cleanup = "zap";
      upgrade = true;
    };

    global.autoUpdate = false;

    brews = import ./brews.nix;
    casks = import ./casks.nix;
    masApps = import ./mas-apps.nix;
  };
}
