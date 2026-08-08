{ ... }:

{
  programs.zsh = {
    localVariables = {
      # Skip syntax highlighting for unusually long pasted command lines.
      ZSH_HIGHLIGHT_MAXLENGTH = 1024;
    };

    syntaxHighlighting = {
      enable = true;
      highlighters = [ "brackets" ];
    };
  };
}
