{ pkgs, ... }:

let
  pathPreview = import ./path-preview.nix { inherit pkgs; };

  previewOptions = [
    "--preview='${pathPreview}/bin/fzf-path-preview {}'"
    "--preview-window='down,50%,border-top'"
    "--bind='ctrl-/:change-preview-window(right,55%,border-left|hidden|down,50%,border-top)'"
    # Legacy terminal input encodes Ctrl-/ as the indistinguishable Ctrl-_ byte.
    "--bind='ctrl-_:change-preview-window(right,55%,border-left|hidden|down,50%,border-top)'"
  ];
in
{
  programs.fzf = {
    enable = true;

    # zsh/fzf.nix loads the integration at an explicit ZLE initialization phase.
    enableZshIntegration = false;

    defaultOptions = [
      # Use the terminal's 16-color palette so fzf follows light and dark themes.
      "--color=base16"

      # Use a native floating pane in modern tmux and Zellij, with height mode
      # as the fallback in a regular terminal.
      "--layout=reverse"
      "--height=60%"
      "--popup=center,85%,75%,border-native"

      # Keep the built-in walker, but avoid common dependency and build trees.
      "--walker-skip=.git,node_modules,target,.direnv,.venv,result"
    ];

    fileWidget.options = previewOptions;
    changeDirWidget.options = previewOptions;

    # Let Atuin own Ctrl-R for shell history search.
    historyWidget = {
      fish.command = "";
      zsh.command = "";
    };
  };
}
