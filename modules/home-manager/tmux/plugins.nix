{
  config,
  neovim,
  pkgs,
}:

let
  catppuccinTmux = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "catppuccin";
    version = "2.3.0";
    src = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "tmux";
      tag = "v2.3.0";
      hash = "sha256-3CJRQCgS8NAN7vOLBjNGiHbGXTIrIyY/FLmfZrXcEYc=";
    };
  };
  resurrectTmux = pkgs.tmuxPlugins.resurrect;
  extraktoTmux = pkgs.tmuxPlugins.extrakto.overrideAttrs {
    version = "0-unstable-2026-03-02";
    src = pkgs.fetchFromGitHub {
      owner = "laktak";
      repo = "extrakto";
      rev = "d1af77988081dae496fa4a1f5e5e6bc9ef66767f";
      hash = "sha256-GziFDuBXdfsnT6XLJK/f58/b4K0BjucnECFE0sSnz3w=";
    };
  };
  tmuxFzf = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-fzf";
    version = "0-unstable-2026-07-26";
    src = pkgs.fetchFromGitHub {
      owner = "sainnhe";
      repo = "tmux-fzf";
      rev = "4cbbbbde54e1b63712d77483b83075fd712d3bb5";
      hash = "sha256-y3elGBQ+xmuY0oiwN9yq5InbAGfTuYyKi/5T6b5iIfs=";
    };
    rtpFilePath = "main.tmux";
  };
  nerdFontWindowNameTmux = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-nerd-font-window-name";
    version = "3.1.0";
    src = pkgs.fetchFromGitHub {
      owner = "joshmedeski";
      repo = "tmux-nerd-font-window-name";
      tag = "v3.1.0";
      hash = "sha256-b6CQdN33hU5li/0LUOHMs7oN8ffVRVQlSf17Twhz2e8=";
    };
    rtpFilePath = "tmux-nerd-font-window-name.tmux";
  };
in
{
  catppuccin = catppuccinTmux;
  extraktoDir = builtins.dirOf extraktoTmux.rtp;
  resurrectDir = builtins.dirOf resurrectTmux.rtp;
  tmuxFzfDir = builtins.dirOf tmuxFzf.rtp;

  list = [
    {
      plugin = resurrectTmux;
      extraConfig = ''
        # Keep runtime snapshots out of the configuration directory. Restore
        # only tmux structure and working directories, never pane contents or
        # arbitrary running processes.
        set -g @resurrect-dir "${config.xdg.stateHome}/tmux/resurrect"
        set -g @resurrect-processes "false"
        set -g @resurrect-capture-pane-contents "off"
      '';
    }
    {
      plugin = extraktoTmux;
      extraConfig = ''
        # keybindings.nix owns the launch key so it appears with a description
        # in tmux's built-in help.
        set -g @extrakto_key "none"
        set -g @extrakto_grab_area "window 2000"
        set -g @extrakto_filter_order "path url word all line"
        set -g @extrakto_clip_mode "tmux_osc52"
        set -g @extrakto_clip_mode_order "tmux_osc52 buffer"
        set -g @extrakto_editor "${neovim}"
      '';
    }
    {
      plugin = tmuxFzf;
      extraConfig = ''
        # Sesh owns sessions and Extrakto owns clipboard extraction. Keep
        # tmux-fzf focused on the remaining native tmux objects.
        set-environment -g TMUX_FZF_ORDER \
          "window|pane|command|keybinding"
        set-environment -g TMUX_FZF_LAUNCH_KEY "F"
      '';
    }
    nerdFontWindowNameTmux
  ];
}
