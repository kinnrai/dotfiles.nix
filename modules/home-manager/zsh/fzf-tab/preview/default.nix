{ pkgs }:

let
  helper = pkgs.writeShellApplication {
    name = "fzf-tab-preview";
    runtimeInputs = with pkgs; [
      bat
      chafa
      coreutils
      delta
      eza
      file
      findutils
      git
      gnused
      jq
      libarchive
      libplist
      lsof
      man-db
      openssh
      procps
      ripgrep
      sqlite
      unixtools.col
      zsh
    ];
    # CLIs whose own completions are being previewed intentionally stay out of
    # runtimeInputs so previews use the executable visible to the current shell.
    # Darwin-only APIs are capability-checked before use.
    text = ''
      # Preserve man-db's default path while making Zsh builtin docs available.
      export MANPATH="${pkgs.zsh.man}/share/man''${MANPATH:+:''${MANPATH}}:"
    '' + builtins.concatStringsSep "\n" (
      map builtins.readFile [
        ./scripts/common.sh
        ./scripts/sqlite.sh
        ./scripts/macho.sh
        ./scripts/path.sh
        ./scripts/git.sh
        ./scripts/process.sh
        ./scripts/help.sh
        ./scripts/shell.sh
        ./scripts/node.sh
        ./scripts/bun.sh
        ./scripts/mise.sh
        ./scripts/shellcheck.sh
        ./scripts/nix.sh
        ./scripts/docker.sh
        ./scripts/ssh.sh
        ./scripts/darwin.sh
        ./scripts/kubernetes.sh
        ./scripts/json.sh
        ./scripts/make.sh
        ./scripts/brew.sh
        ./scripts/tmux.sh
        ./scripts/main.sh
      ]
    );
  };

  plugin = pkgs.writeTextFile {
    name = "fzf-tab-preview-plugin";
    destination = "/share/zsh/plugins/fzf-tab-preview/fzf-tab-preview.plugin.zsh";
    text = import ./routes.nix { preview = helper; };
  };
in
pkgs.symlinkJoin {
  name = "fzf-tab-preview";
  paths = [
    helper
    plugin
  ];
}
