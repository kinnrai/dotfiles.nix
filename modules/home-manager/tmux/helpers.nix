{
  config,
  lib,
  pkgs,
}:

let
  nixvimEnabled = lib.attrByPath [ "programs" "nixvim" "enable" ] false config;
  neovimPackage =
    if nixvimEnabled then
      lib.attrByPath [ "programs" "nixvim" "build" "package" ] pkgs.neovim config
    else
      pkgs.neovim;
  neovim = lib.getExe neovimPackage;

  paneHistoryViewer = pkgs.writeShellScript "tmux-pane-history" ''
    set -eu

    source_pane="$1"
    history_file="$(${pkgs.coreutils}/bin/mktemp "''${TMPDIR:-/tmp}/tmux-pane-history.XXXXXX")"
    cleanup() {
      ${pkgs.coreutils}/bin/rm -f "$history_file"
    }
    trap cleanup EXIT HUP INT TERM

    ${pkgs.tmux}/bin/tmux capture-pane -p -J -S - -t "$source_pane" >"$history_file"
    # capture-pane includes unused rows at the bottom of the visible terminal
    # grid. Position the viewer at the last meaningful line instead of the
    # final padding row, and let that line sit at the bottom of the window.
    ${neovim} -R \
      -c 'setlocal buftype=nofile bufhidden=wipe noswapfile scrolloff=0' \
      -c 'set clipboard=unnamedplus' \
      -c 'lua vim.api.nvim_win_set_cursor(0, { math.max(vim.fn.prevnonblank(vim.fn.line("$")), 1), 0 })' \
      -c 'normal! zb' \
      "$history_file"
  '';

  seshPopup = pkgs.writeShellApplication {
    name = "tmux-sesh";
    runtimeInputs = [
      pkgs.fzf
      pkgs.sesh
      pkgs.tmux
    ];
    text = ''
      selection="$(
        sesh list --icons |
          fzf \
            --ansi \
            --no-sort \
            --border=rounded \
            --border-label=' sessions ' \
            --prompt='⚡  ' \
            --header='Enter: connect  Ctrl-d: kill  Tab/Shift-Tab: move' \
            --bind='tab:down,btab:up' \
            --bind='ctrl-d:execute(tmux kill-session -t {2..})+reload(sesh list --icons)' \
            --preview='sesh preview {}' \
            --preview-window='right:55%'
      )"

      if [[ -n "$selection" ]]; then
        exec sesh connect "$selection"
      fi
    '';
  };
in
{
  inherit neovim paneHistoryViewer seshPopup;
}
