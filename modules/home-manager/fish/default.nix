{ ... }:
{
  imports = [
    ./plugins.nix
    ./themes.nix
  ];

  programs.fish = {
    enable = true;

    shellAbbrs = {
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

    binds = {
      # Keep Aerospace on alt and make autosuggestion acceptance semantic:
      # right accepts one char, ctrl-f accepts one word, ctrl-n accepts all,
      # and ctrl-left/right recover prevd/nextd-style navigation.
      right = {
        mode = "insert";
        command = "forward-single-char";
      };
      ctrl-f = {
        mode = "insert";
        command = "forward-word";
      };
      ctrl-right = {
        mode = "insert";
        command = "nextd-or-forward-word";
      };
      ctrl-left = {
        mode = "insert";
        command = "prevd-or-backward-word";
      };
    };

    functions = {
      y = {
        description = "A shell wrapper that provides the ability to change the current working directory when exiting Yazi";
        body = ''
          set tmp (mktemp -t "yazi-cwd.XXXXXX")
          command yazi $argv --cwd-file="$tmp"
          if read -z cwd < "$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
              builtin cd -- "$cwd"
          end
          rm -f -- "$tmp"
        '';
      };
    };

    completions = {
      bdcli = ''
        if command -sq bdcli
            bdcli completion fish | source
        end
      '';
    };

    interactiveShellInit = ''
      set -g fish_key_bindings fish_vi_key_bindings

      set -l brew_prefix (brew --prefix)
      if test -d "$brew_prefix/share/fish/completions"
          set -p fish_complete_path "$brew_prefix/share/fish/completions"
      end

      if test -d "$brew_prefix/share/fish/vendor_completions.d"
          set -p fish_complete_path "$brew_prefix/share/fish/vendor_completions.d"
      end
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
