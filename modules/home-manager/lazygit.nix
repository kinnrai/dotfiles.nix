{ ... }:

{
  programs.lazygit = {
    enable = true;

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
