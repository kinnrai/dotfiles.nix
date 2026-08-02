{ pkgs, ... }:

let
  preview = pkgs.writeShellApplication {
    name = "fzf-preview";
    runtimeInputs = with pkgs; [
      bat
      eza
      file
    ];
    text = ''
      path="''${1:-}"

      if [[ -z "$path" ]]; then
        exit 0
      elif [[ -d "$path" ]]; then
        exec eza \
          --tree \
          --level=2 \
          --color=always \
          --icons=always \
          --group-directories-first \
          -- "$path"
      elif [[ -f "$path" ]]; then
        exec bat \
          --color=always \
          --style=numbers \
          --line-range=:500 \
          -- "$path"
      else
        exec file --brief -- "$path"
      fi
    '';
  };

  previewOptions = [
    "--preview='${preview}/bin/fzf-preview {}'"
    "--preview-window='right,55%,border-left,<100(down,50%,border-top)'"
    "--bind='ctrl-/:toggle-preview'"
  ];
in
{
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;

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

    # Let Atuin own Ctrl-R for fish history search.
    historyWidget.fish.command = "";
  };
}
