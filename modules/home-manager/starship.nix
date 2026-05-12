{ config, ... }:

{
  programs.starship = {
    enable = true;

    # Do not put Starship in interactiveShellInit. fish-async-prompt renders
    # the prompt in a non-interactive fish subprocess, so that code would not
    # run there. As a result, fish_prompt/fish_right_prompt would be missing
    # and the async prompt flow would break.
    #
    # @see https://github.com/acomagu/fish-async-prompt/issues/74
    # @see https://github.com/acomagu/fish-async-prompt/issues/82
    enableFishIntegration = true;
    enableInteractive = false;

    configPath = "${config.xdg.configHome}/starship/starship.toml";
  };
}
