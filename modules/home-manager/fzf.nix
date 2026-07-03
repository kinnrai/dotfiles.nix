{ ... }:

{
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;

    # Let Atuin own Ctrl-R for fish history search.
    historyWidget.fish.command = "";
  };
}
