{ pkgs, ... }:
{
  programs.fish = {
    enable = true;

    plugins = [
      {
        name = "async-prompt";
        src = pkgs.fishPlugins.async-prompt.src;
      }
      {
        name = "puffer";
        src = pkgs.fishPlugins.puffer.src;
      }
    ];

    shellAbbrs = {
      cat = "bat --paging=never";
      py = "python";
      vim = "nvim";

      "-h" = {
        position = "anywhere";
        expansion = "-h 2>&1 | bat --language=help --style=plain";
      };
      "--help" = {
        position = "anywhere";
        expansion = "--help 2>&1 | bat --language=help --style=plain";
      };
    };

    interactiveShellInit = ''
      fish_config theme choose catppuccin-macchiato >/dev/null

      # fish-async-prompt renders Starship in a non-interactive child process.
      # Export the binding mode so that child can preserve vi mode in the prompt.
      set -gx fish_key_bindings fish_vi_key_bindings
    '';

    shellInitLast = ''
      # Atuin rebinds ctrl-r globally after fish_vi_key_bindings loads.
      # Restore redo in vi normal mode while keeping atuin in insert mode.
      if test "$fish_key_bindings" = fish_vi_key_bindings
          bind -M default ctrl-r redo
      end
    '';
  };
}
