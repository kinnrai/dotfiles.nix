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
    defaultKeymap = "viins";

    localVariables = {
      # Zsh measures KEYTIMEOUT in hundredths of a second.
      KEYTIMEOUT = 10;
    };

    # Traditional vi Backspace cannot cross the point where insert mode
    # started. Use the regular widget for modern, unrestricted deletion.
    initContent = initOrder.editingFixups ''
      bindkey -M viins '^?' backward-delete-char
      bindkey -M viins '^H' backward-delete-char
    '';

    # zsh-abbr is contributed to the ordinary plugin list by its Home Manager
    # module. Append these so autopair wraps its Space widget, then let the
    # clipboard plugin wrap the completed vi-mode keymaps.
    plugins = lib.mkAfter [
      {
        name = "zsh-autopair";
        src = pkgs.zsh-autopair;
        file = "share/zsh/zsh-autopair/autopair.zsh";
      }
      {
        name = "zsh-system-clipboard";
        src = pkgs.zsh-system-clipboard;
        file = "share/zsh/zsh-system-clipboard/zsh-system-clipboard.zsh";
      }
    ];
  };
}
