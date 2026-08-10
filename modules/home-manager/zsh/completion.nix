{
  config,
  lib,
  pkgs,
  ...
}:

let
  completionCache = "${config.xdg.cacheHome}/zsh/completion";
  initOrder = import ./init-order.nix { inherit lib; };
  cargoCompletionRustup = pkgs.writeShellScriptBin "rustup" ''
    if [[ $# -eq 3 && $1 == toolchain && $2 == list && $3 == -q ]]; then
      exit 0
    fi
    exit 1
  '';
  runtimeCompletions = pkgs.runCommandLocal "runtime-zsh-completions" {
    nativeBuildInputs = [
      pkgs.bun
      pkgs.deno
    ];
  } ''
    export HOME="$TMPDIR"
    mkdir -p "$out/share/zsh/site-functions"
    deno completions --dynamic zsh > "$out/share/zsh/site-functions/_deno"
    substituteInPlace "$out/share/zsh/site-functions/_deno" \
      --replace-fail _clap_dynamic_completer_deno _deno
    echo '_deno "$@"' >> "$out/share/zsh/site-functions/_deno"
    SHELL=zsh bun completions > "$out/share/zsh/site-functions/_bun"
    # Keep the repository-wide completion description format; Bun otherwise
    # hardcodes a green format from inside the lazily loaded function.
    sed -i '/zstyle .*bun.*format/d' "$out/share/zsh/site-functions/_bun"
    echo '_bun "$@"' >> "$out/share/zsh/site-functions/_bun"

    # TODO: Remove this local rustup stub once Cargo 1.99 reaches nixpkgs.
    # Cargo 1.97's dynamic completion unconditionally executes rustup and
    # panics when a Nix-managed Rust toolchain does not install it. The stub is
    # scoped to completion generation and returns an empty toolchain list.
    # https://github.com/rust-lang/cargo/issues/17260
    install -m 0644 ${pkgs.cargo}/share/zsh/site-functions/_cargo \
      "$out/share/zsh/site-functions/_cargo"
    sed -i '/CARGO_COMPLETE="zsh"/i\
        PATH="${cargoCompletionRustup}/bin:$PATH" \\' \
      "$out/share/zsh/site-functions/_cargo"
    echo '_clap_dynamic_completer_cargo "$@"' >> \
      "$out/share/zsh/site-functions/_cargo"
  '';
in
{
  # Home Manager exposes package completions through the user profile, whose
  # site-functions directory is added to fpath before compinit runs. Deno and
  # Bun remain managed by Mise; only their upstream-generated completion files
  # come from locked nixpkgs so shell startup does not execute either runtime.
  # The higher priority also lets the patched Cargo completion shadow the copy
  # shipped by Cargo itself.
  home.packages = [
    pkgs.zsh-completions
    (lib.hiPrio runtimeCompletions)
  ];

  programs.zsh = {
    completionInit = ''
      autoload -Uz compinit
      mkdir -p "${completionCache}"
      compinit -d "${config.xdg.cacheHome}/zsh/zcompdump"
    '';

    initContent = lib.mkMerge [
      (initOrder.completionStyles ''
        zstyle ':completion:*' group-name ""
        zstyle ':completion:*:descriptions' format '[%d]'
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
        zstyle ':completion:*' menu no
        zstyle ':completion:*' use-cache true
        zstyle ':completion:*' cache-path "${completionCache}"
      '')

      # Correct upstream completion behavior after compinit has registered its
      # functions, but before fzf-tab starts consuming their contexts.
      (initOrder.completionOverrides ''
        ${builtins.readFile ./completion/ssh-hosts.zsh}
        ${builtins.readFile ./completion/otool.zsh}
      '')

      # Refresh completions after tools such as direnv and nix develop update
      # XDG_DATA_DIRS or fpath. Keep normal compinit security checks enabled.
      (initOrder.completionSync ''
        zstyle ':completion-sync:xdg' enabled true
        zstyle ':completion-sync:path' enabled false
        zstyle ':completion-sync:compinit:optimizations:fast-add' enabled false
        zstyle ':completion-sync:compinit:optimizations:no-caching' enabled false
        zstyle ':completion-sync:compinit:compat:zsh-autocomplete' enabled false
        source ${pkgs.zsh-completion-sync}/share/zsh-completion-sync/zsh-completion-sync.plugin.zsh
      '')
    ];
  };
}
