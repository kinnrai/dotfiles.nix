{ userHome, ... }:
{
  imports = [
    ./plugins.nix
    ./themes.nix
  ];

  home.sessionVariables = {
    XDG_CACHE_HOME = "${userHome}/.cache";
    XDG_CONFIG_HOME = "${userHome}/.config";
    XDG_DATA_HOME = "${userHome}/.local/share";
    XDG_STATE_HOME = "${userHome}/.local/state";

    ANDROID_HOME = "${userHome}/Library/Android/sdk";
    ANDROID_USER_HOME = "${userHome}/.local/share/android";
    CARGO_HOME = "${userHome}/.local/share/cargo";
    CP_HOME_DIR = "${userHome}/.local/share/cocoapods";
    DOCKER_CONFIG = "${userHome}/.config/docker";
    GOPATH = "${userHome}/.local/share/go";
    GOCACHE = "${userHome}/.cache/go/cache";
    GOMODCACHE = "${userHome}/.cache/go/mod";
    GRADLE_USER_HOME = "${userHome}/.local/share/gradle";
    KONAN_DATA_DIR = "${userHome}/.local/share/konan";
    NPM_CONFIG_USERCONFIG = "${userHome}/.config/npm/npmrc";
    NPM_CONFIG_CACHE = "${userHome}/.cache/npm";
    PYTHON_HISTORY = "${userHome}/.local/state/python_history";
    RUSTUP_HOME = "${userHome}/.local/share/rustup";

    SSH_AUTH_SOCK = "${userHome}/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock";
    MAS_NO_AUTO_INDEX = "1";
    LANG = "zh_CN.UTF-8";
    EDITOR = "nvim";
  };

  home.sessionPath = [
    "${userHome}/Library/Android/sdk/platform-tools"
    "${userHome}/.local/share/cargo/bin"
    "${userHome}/.pub-cache/bin"
    "${userHome}/.local/share/go/bin"
    "${userHome}/.local/bin"
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

    shellInit = ''
      # Keep Starship out of interactiveShellInit. fish-async-prompt spawns a
      # non-interactive fish subprocess to render prompt functions, and Home
      # Manager only runs interactiveShellInit behind `status is-interactive`.
      # If Starship is initialized there, the async child shell never defines
      # fish_prompt/fish_right_prompt, which breaks the wrapped prompt path.
      #
      # @see https://github.com/acomagu/fish-async-prompt/issues/74
      # @see https://github.com/acomagu/fish-async-prompt/issues/82
      starship init fish | source
    '';

    interactiveShellInit = ''
      set -g fish_key_bindings fish_vi_key_bindings
      set -g fish_transient_prompt 1

      atuin init fish | source
      mise activate fish | source
      zoxide init fish --cmd cd | source

      set -l brew_prefix (brew --prefix)
      if test -d "$brew_prefix/share/fish/completions"
          set -p fish_complete_path "$brew_prefix/share/fish/completions"
      end

      if test -d "$brew_prefix/share/fish/vendor_completions.d"
          set -p fish_complete_path "$brew_prefix/share/fish/vendor_completions.d"
      end
    '';
  };
}
