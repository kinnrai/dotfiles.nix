{
  lib,
  pkgs,
  ...
}:

let
  initOrder = import ./init-order.nix { inherit lib; };
in
{
  programs.zsh = {
    localVariables = {
      # Avoid fetching suggestions for large pasted command lines.
      ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE = 20;
    };

    autosuggestion = {
      enable = true;

      # The Home Manager option only accepts built-in strategies. Configure
      # the externally supplied abbreviations strategy after loading it.
      strategy = [ ];
    };

    initContent = lib.mkMerge [
      # Home Manager sources ordinary plugins at order 900 and initializes
      # history at 910. Extend autosuggestions after both dependencies.
      (initOrder.autosuggestionExtensions ''
        source ${pkgs.zsh-autosuggestions-abbreviations-strategy}/share/zsh/site-functions/zsh-autosuggestions-abbreviations-strategy.zsh

        # Completion suggestions run in a private zpty. After a Tab completes
        # a common prefix, its inherited fzf-tab state can open an invisible
        # picker there. Restore native completion only in that child, before
        # autosuggestions binds its capture widget; normal Tab is unchanged.
        if (( $+functions[_zsh_autosuggest_capture_setup] &&
              ! $+functions[_local_autosuggest_capture_setup] )); then
          functions[_local_autosuggest_capture_setup]=$functions[_zsh_autosuggest_capture_setup]
          _zsh_autosuggest_capture_setup() {
            (( $+functions[disable-fzf-tab] )) && disable-fzf-tab
            _local_autosuggest_capture_setup "$@"
          }
        fi
      '')

      # Atuin prepends its own autosuggestion strategy during integration.
      # Restore the intended precedence while leaving Ctrl-R under Atuin.
      (initOrder.autosuggestionStrategy ''
        ZSH_AUTOSUGGEST_STRATEGY=(abbreviations history completion)
      '')
    ];
  };
}
