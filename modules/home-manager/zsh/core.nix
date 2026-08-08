{
  config,
  lib,
  ...
}:

{
  programs.zsh = {
    autocd = true;

    # Home Manager derives history options separately; append explicit options
    # so the generated configuration keeps the same stable ordering.
    setOptions = lib.mkAfter [
      "NO_BANG_HIST"
      "INTERACTIVE_COMMENTS"
      "HIST_NO_STORE"
      "HIST_REDUCE_BLANKS"
    ];

    history = {
      path = "${config.xdg.stateHome}/zsh/history";
      size = 120000;
      save = 100000;
      extended = true;
      expireDuplicatesFirst = true;
      findNoDups = true;
      ignoreAllDups = true;
      saveNoDups = true;
    };
  };
}
