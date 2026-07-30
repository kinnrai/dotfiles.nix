{ catppuccin, pkgs }:

let
  # Catppuccin 2.3.0 does not include module-specific colors in
  # @catppuccin_reset. Its modules initialize these options only once, so an
  # appearance change otherwise combines the new background with stale text
  # and icon colors from the previous flavor. Upstream tracks the incomplete
  # reset in issue #591 and proposes a complete reset in PR #592:
  # https://github.com/catppuccin/tmux/issues/591
  # https://github.com/catppuccin/tmux/pull/592
  #
  # Until a release contains that fix, reset the derived colors for the status
  # modules used below. Add new modules to this list when enabling them, and
  # remove this workaround after upgrading to a release containing the fix.
  catppuccinStatusModuleReset = builtins.concatStringsSep "\n" (
    map
      (module: ''
        set -guq @catppuccin_${module}_color
        set -guq @catppuccin_status_${module}_icon_fg
        set -guq @catppuccin_status_${module}_icon_bg
        set -guq @catppuccin_status_${module}_text_fg
        set -guq @catppuccin_status_${module}_text_bg
      '')
      [
        "directory"
        "session"
      ]
  );

  # Catppuccin resets user options when changing flavor. Load it once to clear
  # the previous flavor, restore the custom options, then load it again to
  # render every derived style with the new palette.
  mkCatppuccinTheme =
    flavor:
    pkgs.writeText "tmux-catppuccin-${flavor}.conf" ''
      set -g @catppuccin_flavor "${flavor}"
      set -g @catppuccin_reset "true"
      run-shell ${catppuccin.rtp}

      set -g @catppuccin_flavor "${flavor}"
      set -g @catppuccin_status_background "default"
      set -g @catppuccin_window_status_style "rounded"
      set -g @catppuccin_window_text " #W"
      set -g @catppuccin_window_current_text " #W"
      set -g @catppuccin_window_flags "icon"
      set -g @catppuccin_window_flags_icon_current ""
      set -g @catppuccin_pane_active_border_style \
        "##{?pane_in_mode,fg=#{@thm_yellow},##{?pane_synchronized,fg=#{@thm_red},fg=#{@thm_lavender}}}"
      ${catppuccinStatusModuleReset}
      run-shell ${catppuccin.rtp}

      set -g status-position bottom
      set -g status-justify centre
      set -g status-left-length 60
      set -g status-right-length 100
      set -g status-left "#{E:@catppuccin_status_session}"
      set -g status-right "#{E:@catppuccin_status_directory}"
      set -ag status-left \
        "#{?session_many_attached,#[fg=#{@thm_blue}]#[bg=default]#[fg=#{@thm_crust}]#[bg=#{@thm_blue}]#[bold] 󰍹 #{session_attached} #[fg=#{@thm_blue}]#[bg=default]#[nobold]#[default],}"
      set -ag status-left \
        "#{?pane_synchronized,#[fg=#{@thm_red}]#[bg=default]#[fg=#{@thm_crust}]#[bg=#{@thm_red}]#[bold] SYNC #[fg=#{@thm_red}]#[bg=default]#[nobold]#[default],}"
      set -wgF copy-mode-line-number-style "fg=#{@thm_overlay_0}"

      if-shell -F "#{client_id}" "refresh-client -S"
    '';

  lightTheme = mkCatppuccinTheme "latte";
  darkTheme = mkCatppuccinTheme "macchiato";
in
{
  inherit darkTheme lightTheme;

  extraConfig = ''
    # Reload the matching theme when Ghostty reports a macOS appearance
    # change. On first start use Macchiato; on later reloads preserve the
    # flavor currently selected by the active client.
    set-hook -g client-light-theme {
      source-file ${lightTheme}
    }
    set-hook -g client-dark-theme {
      source-file ${darkTheme}
    }
    if-shell -F "#{==:#{@catppuccin_flavor},latte}" \
      "source-file ${lightTheme}" \
      "source-file ${darkTheme}"
  '';
}
