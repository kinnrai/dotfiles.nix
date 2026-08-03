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
      set -g fish_key_bindings fish_vi_key_bindings
    '';

    shellInitLast = ''
      # Atuin rebinds ctrl-r globally after fish_vi_key_bindings loads.
      # Restore redo in vi normal mode while keeping atuin in insert mode.
      if test "$fish_key_bindings" = fish_vi_key_bindings
          bind -M default ctrl-r redo
      end
    '';
  };

  # Fish loads conf.d before Home Manager's plugin loaders, so async-prompt sees
  # this setting before it initializes. SIGUSR1 is reserved by direnv-instant.
  xdg.configFile."fish/conf.d/00-plugin-options.fish".text = ''
    set -g async_prompt_signal_number SIGUSR2
  '';
}
