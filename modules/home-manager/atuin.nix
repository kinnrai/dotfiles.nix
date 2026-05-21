{ ... }:

{
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;

    daemon.enable = true;
    forceOverwriteSettings = true;

    flags = [ "--disable-up-arrow" ];

    settings = {
      ctrl_n_shortcuts = true;
      enter_accept = false;

      keymap_mode = "auto";
      keymap_cursor = {
        emacs = "blink-block";
        vim_insert = "blink-bar";
        vim_normal = "steady-block";
      };

      stats.common_subcommands = [
        "docker"
        "git"
        "kubectl"
        "nix"
      ];

      keys.scroll_exits = false;

      sync.records = true;

      ui.columns = [
        "duration"
        "time"
        "host"
        "command"
      ];
    };
  };
}
