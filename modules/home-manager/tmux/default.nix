{
  config,
  lib,
  pkgs,
  ...
}:

let
  helpers = import ./helpers.nix { inherit config lib pkgs; };
  plugins = import ./plugins.nix {
    inherit config pkgs;
    inherit (helpers) neovim;
  };
  theme = import ./theme.nix {
    inherit pkgs;
    inherit (plugins) catppuccin;
  };
  keybindings = import ./keybindings.nix {
    inherit config pkgs;
    inherit (helpers) paneHistoryViewer seshPopup;
    inherit (plugins) extraktoDir resurrectDir tmuxFzfDir;
  };
in
{
  home.packages = [ pkgs.sesh ];

  xdg.configFile."sesh/sesh.toml".text = ''
    strict_mode = true
    separator_aware = true
    sort_order = [ "tmux", "config", "zoxide" ]

    [default_session]
    preview_command = "${pkgs.eza}/bin/eza --tree --level=2 --color=always --icons=always --group-directories-first {}"

    [tui]
    prompt = "⚡  "
    placeholder = "Filter sessions..."
    show_icons = true
  '';

  xdg.configFile."tmux/tmux-nerd-font-window-name.yml".text = ''
    config:
      fallback-icon: ""
      show-name: true
      icon-position: "left"

    icons:
      claude: "󰚩"
      codex: "󰚩"
      opencode: "󰚩"
  '';

  programs.tmux = {
    enable = true;

    # Keep the upstream prefix (Ctrl-b) so the same muscle memory works on
    # unconfigured and remote tmux installations.
    shortcut = "b";

    # This Mac talks to tmux through a local terminal, so Escape does not need
    # an ambiguity delay. VI keys match Fish and Neovim.
    escapeTime = 0;
    keyMode = "vi";
    clock24 = true;
    customPaneNavigationAndResize = true;
    resizeAmount = 5;

    focusEvents = true;
    historyLimit = 50000;
    mouse = true;
    baseIndex = 1;
    terminal = "tmux-256color";

    plugins = plugins.list;

    extraConfig = ''
      # Preserve useful context and make repeated navigation feel immediate.
      set -g renumber-windows on
      set -g detach-on-destroy off
      set -g scroll-on-clear on
      set -g repeat-time 600
      set -g display-time 3000
      set -g status-interval 5
      set -g activity-action other
      set -g bell-action other
      set -g visual-activity off
      set -g visual-bell off
      set -wg monitor-activity on
      set -wg copy-mode-line-numbers hybrid
      set -g pane-border-indicators arrows
      set -g popup-border-lines rounded
      set -g menu-border-lines rounded
      set -g set-titles on
      set -g set-titles-string "#S:#I.#P #W"

      # Keep Ctrl-b as the portable primary prefix and add Ctrl-a as an
      # ergonomic alternative. Pressing Ctrl-a twice sends a literal Ctrl-a
      # to applications such as shells and terminal UIs.
      set -g prefix2 C-a
      bind-key -N "Send Ctrl-a to the active pane" \
        C-a send-prefix -2

      # Ghostty supports OSC 52. "external" lets tmux write the system
      # clipboard without trusting applications inside panes to write it.
      set -s set-clipboard external

      ${theme.extraConfig}
      ${keybindings}
    '';
  };
}
