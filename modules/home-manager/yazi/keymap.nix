let
  smartSwitchKeymap = builtins.genList (
    index:
    let
      key = index + 1;
    in
    {
      on = toString key;
      run = "plugin smart-switch ${toString index}";
      desc = "Switch to or create tab ${toString key}";
    }
  ) 9;
in
smartSwitchKeymap ++ [
  {
    on = "f";
    run = "plugin smart-filter";
    desc = "Filter files continuously";
  }
  {
    on = "l";
    run = "plugin smart-enter";
    desc = "Enter the child directory, or open the file";
  }
  {
    on = "y";
    run = [
      "yank"
      "plugin clipboard -- --action=copy --notify-unknown-display-server"
    ];
    desc = "Yank files and copy them to the system clipboard";
  }
  {
    on = "x";
    run = [
      "yank --cut"
      "plugin clipboard -- --action=copy --notify-unknown-display-server"
    ];
    desc = "Cut files and copy them to the system clipboard";
  }
  {
    on = "p";
    run = "plugin smart-paste";
    desc = "Paste into the hovered directory or CWD";
  }
  {
    on = [
      "c"
      "a"
    ];
    run = "plugin archive-selected";
    desc = "Archive selected files";
  }
  {
    on = [
      "c"
      "v"
    ];
    run = "plugin clipboard -- --action=paste --notify-unknown-display-server";
    desc = "Paste files from the system clipboard";
  }
  {
    on = [
      "c"
      "y"
    ];
    run = "plugin copy-content";
    desc = "Copy file contents or a directory tree";
  }
  {
    on = [
      "c"
      "="
    ];
    run = "plugin diff";
    desc = "Diff the selected file with the hovered file";
  }
  {
    on = "T";
    run = "plugin toggle-pane max-preview";
    desc = "Maximize or restore the preview pane";
  }
  {
    on = [
      "m"
      "i"
    ];
    run = "plugin mediainfo -- toggle-metadata";
    desc = "Toggle media metadata";
  }
  {
    on = [
      "m"
      "v"
    ];
    run = "plugin mediainfo -- toggle-preview";
    desc = "Toggle the media preview image";
  }
  {
    on = "q";
    run = "plugin confirm-quit";
    desc = "Quit after confirming when multiple tabs are open";
  }
  {
    on = "<C-t>";
    run = "plugin close-and-restore-tab restore";
    desc = "Restore the last closed tab";
  }
  {
    on = [
      "t"
      "t"
    ];
    run = "plugin smart-tab";
    desc = "Create a tab and enter the hovered directory";
  }
  {
    on = [
      "g"
      "b"
    ];
    run = "plugin git-actions browse";
    desc = "Open the Git repository in the browser";
  }
  {
    on = [
      "g"
      "s"
    ];
    run = "plugin vcs-files";
    desc = "Show Git file changes";
  }
  {
    on = [
      "g"
      "i"
    ];
    run = "plugin lazygit";
    desc = "Run Lazygit";
  }
  {
    on = [
      "g"
      "r"
    ];
    run = "plugin git-actions root";
    desc = "Go to the Git repository root";
  }
  {
    on = [
      "c"
      "m"
    ];
    run = "plugin chmod";
    desc = "Change permissions on selected files";
  }
  {
    on = "M";
    run = "plugin mount";
    desc = "Open the mount manager";
  }
]
