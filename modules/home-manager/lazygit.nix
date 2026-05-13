{ ... }:

{
  programs.lazygit = {
    enable = true;
    enableFishIntegration = true;

    # User config of lazygit
    #
    # @see https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md
    settings = {
      gui.showNumstatInFilesView = true;
      gui.nerdFontsVersion = "3";
      git.autoFetch = false;
      quitOnTopLevelReturn = true;
    };
  };
}
