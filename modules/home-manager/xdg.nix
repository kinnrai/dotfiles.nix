{ config, ... }:

{
  # Define the standard XDG directories and export their corresponding
  # variables. This is also the source of truth for program-specific paths
  # below.
  xdg.enable = true;
  xdg.localBinInPath = true;
  home.preferXdgDirectories = true;

  # Programs that do not natively honour XDG but expose a directory override.
  home.sessionVariables = {
    # Configuration
    DOCKER_CONFIG = "${config.xdg.configHome}/docker";
    GOENV = "${config.xdg.configHome}/go/env";
    NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/npmrc";

    # Regenerable caches
    GOCACHE = "${config.xdg.cacheHome}/go/cache";
    GOMODCACHE = "${config.xdg.cacheHome}/go/mod";
    NPM_CONFIG_CACHE = "${config.xdg.cacheHome}/npm";
    PUB_CACHE = "${config.xdg.cacheHome}/dart/pub-cache";

    # Persistent application data
    ANDROID_USER_HOME = "${config.xdg.dataHome}/android";
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
    CP_HOME_DIR = "${config.xdg.dataHome}/cocoapods";
    DART_DATA_HOME = "${config.xdg.dataHome}/dart";
    GOPATH = "${config.xdg.dataHome}/go";
    GRADLE_USER_HOME = "${config.xdg.dataHome}/gradle";
    HF_TOKEN_PATH = "${config.xdg.dataHome}/huggingface/token";
    KONAN_DATA_DIR = "${config.xdg.dataHome}/konan";

    # Persistent, non-portable state
    NODE_REPL_HISTORY = "${config.xdg.stateHome}/node_repl_history";
    PYTHON_HISTORY = "${config.xdg.stateHome}/python_history";
  };
}
