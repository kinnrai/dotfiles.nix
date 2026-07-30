{
  config,
  extraktoDir,
  paneHistoryViewer,
  pkgs,
  resurrectDir,
  seshPopup,
  tmuxFzfDir,
}:

''
  # Preserve the active pane's working directory when creating panes and
  # windows. Keep the upstream split bindings and add mnemonic alternatives.
  bind-key -N "Create a window in the current directory" \
    c new-window -c "#{pane_current_path}"
  bind-key -N "Split the pane into top and bottom panes" \
    '"' split-window -v -c "#{pane_current_path}"
  bind-key -N "Split the pane into left and right panes" \
    % split-window -h -c "#{pane_current_path}"
  bind-key -N "Split the pane into top and bottom panes" \
    - split-window -v -c "#{pane_current_path}"
  bind-key -N "Split the pane into left and right panes" \
    | split-window -h -c "#{pane_current_path}"
  bind-key -N "Select window 10" \
    0 select-window -t :=10

  # Sesh combines existing tmux sessions, declarative entries, and zoxide
  # directories. fzf supplies a preview while Sesh remains managed by
  # nixpkgs rather than as a mutable tmux plugin.
  bind-key -N "Find or create a session with Sesh" \
    O display-popup -E -w 80% -h 90% -d "#{pane_current_path}" \
    -T "Sessions" "${seshPopup}/bin/tmux-sesh"
  bind-key -N "Switch to the previously attached session with Sesh" \
    BTab run-shell "${pkgs.sesh}/bin/sesh last"

  # tmux-fzf handles native windows, panes, commands, and key bindings.
  # Pass the invoking client explicitly so actions target the right screen
  # when multiple terminals are attached to the same tmux server.
  bind-key -N "Manage windows, panes, commands, and keys with fzf" \
    F run-shell -b \
    "TMUX_FZF_CLIENT='#{client_tty}' ${tmuxFzfDir}/main.sh"

  # Declare plugin actions here so they appear in tmux's built-in help. The
  # Resurrect plugin installs the same default keys first; these bindings add
  # descriptions without changing its save and restore behavior.
  bind-key -N "Extract text from pane history with Extrakto" \
    Tab run-shell "\"${extraktoDir}/scripts/open.sh\" \"#{pane_id}\""
  bind-key -N "Save tmux sessions and layouts with Resurrect" \
    C-s run-shell "${resurrectDir}/scripts/save.sh"
  bind-key -N "Restore tmux sessions and layouts with Resurrect" \
    C-r run-shell "${resurrectDir}/scripts/restore.sh"

  # These aliases make session and window switching symmetrical without
  # removing tmux's built-in n, p, and l bindings.
  bind-key -r -N "Select the previous window" \
    C-h previous-window
  bind-key -r -N "Select the next window" \
    C-l next-window

  # Popups are for short-lived work that should inherit the current project
  # without occupying a permanent pane.
  bind-key -N "Open LazyGit in the current directory" \
    g display-popup -E -w 90% -h 90% -d "#{pane_current_path}" \
    -T "LazyGit" "${pkgs.lazygit}/bin/lazygit"

  # Synchronised input is useful but dangerous when left enabled. The
  # Catppuccin theme renders a red pane border and a SYNC status segment.
  bind-key -N "Toggle synchronized input for this window" \
    S set-option -w synchronize-panes \; \
    display-message "Synchronized input: #{?pane_synchronized,on,off}"

  # Make VI copy mode follow familiar visual-selection semantics. Copies
  # also reach the macOS clipboard through set-clipboard above.
  bind-key -N "Enter copy mode" \
    Enter copy-mode
  bind-key -T copy-mode-vi -N "Begin a visual selection" \
    v send-keys -X begin-selection
  bind-key -T copy-mode-vi -N "Toggle rectangular visual selection" \
    C-v send-keys -X rectangle-toggle
  bind-key -T copy-mode-vi -N "Copy the selection and leave copy mode" \
    y send-keys -X copy-selection-and-cancel

  # Search the complete retained history in a read-only Neovim floating
  # pane. Unlike display-popup, a tmux 3.7 floating pane supports OSC 11
  # and theme update sequences, so Neovim follows Ghostty without an
  # explicit background override. run-shell expands the source pane ID
  # before the floating pane becomes active.
  # Joined wrapped lines are easier to search and ordinary yanks reach the
  # macOS clipboard; the temporary file also keeps Neovim attached to a TTY.
  bind-key -N "Search pane history in Neovim" \
    e run-shell -b \
    "${pkgs.tmux}/bin/tmux new-pane -x 90% -y 90% -X 5% -Y 5% \
    -t #{q:pane_id} -c #{q:pane_current_path} \
    ${paneHistoryViewer} #{q:pane_id}"

  # Reload the declaratively generated file without restarting the server.
  bind-key -N "Reload the tmux configuration" \
    r source-file "${config.xdg.configHome}/tmux/tmux.conf" \; \
    display-message "tmux configuration reloaded"
''
