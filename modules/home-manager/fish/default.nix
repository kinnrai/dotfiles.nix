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
      "\\cg".command = "_sgpt_commandline";

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
      "_sgpt_commandline" = {
        description = "Use the current command line as an sgpt shell prompt and replace it with the generated command";
        body = ''
          set -l _sgpt_prompt (commandline)

          if test -z "$_sgpt_prompt"
              return
          end

          commandline -a "⌛"
          commandline -f end-of-line

          set -l _sgpt_output (echo "$_sgpt_prompt" | sgpt --shell --no-interaction)

          if test $status -eq 0
              commandline -r -- (string trim "$_sgpt_output")
              commandline -a "  # $_sgpt_prompt"
          else
              commandline -f backward-delete-char
              commandline -a "  # ERROR: sgpt command failed"
          end
        '';
      };

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
