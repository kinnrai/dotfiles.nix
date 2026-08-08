{
  lib,
  pkgs,
  ...
}:

let
  initOrder = import ./init-order.nix { inherit lib; };
in
{
  # Load the regular Fzf widgets after compinit, but before fzf-tab takes
  # ownership of Tab. Atuin remains responsible for Ctrl-R.
  programs.zsh.initContent = initOrder.fzfWidgets ''
    if [[ $options[zle] = on ]]; then
      export FZF_CTRL_R_COMMAND=""
      source <(${lib.getExe pkgs.fzf} --zsh)
    fi
  '';
}
