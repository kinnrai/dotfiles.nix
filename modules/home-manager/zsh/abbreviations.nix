{ ... }:

{
  programs.zsh.zsh-abbr = {
    enable = true;

    # Match the command abbreviations provided by the fish configuration.
    abbreviations = {
      cat = "bat --paging=never";
      py = "python";
      vim = "nvim";
    };
    globalAbbreviations = {
      "-h" = "-h 2>&1 | bat --language=help --style=plain";
      "--help" = "--help 2>&1 | bat --language=help --style=plain";
    };
  };
}
