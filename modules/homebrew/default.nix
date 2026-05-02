{
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      cleanup = "zap";
      upgrade = false;
    };

    global.autoUpdate = false;

    brews = import ./brews.nix;
    casks = import ./casks.nix;
  };
}
