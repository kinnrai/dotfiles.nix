{ lib, pkgs }:

let
  archiveSelected = pkgs.writeTextDir "main.lua" (builtins.readFile ./lua/archive.lua);
  copyContent = pkgs.writeTextDir "main.lua" (builtins.readFile ./lua/copy-content.lua);
  confirmQuit = pkgs.writeTextDir "main.lua" (builtins.readFile ./lua/confirm-quit.lua);
  gitActions = pkgs.writeTextDir "main.lua" (builtins.readFile ./lua/git-actions.lua);
  smartSwitch = pkgs.writeTextDir "main.lua" (builtins.readFile ./lua/smart-switch.lua);
  smartTab = pkgs.writeTextDir "main.lua" (builtins.readFile ./lua/smart-tab.lua);
  symlinkStatus = pkgs.writeTextDir "main.lua" (builtins.readFile ./lua/symlink-status.lua);
in
{
  archive-selected = archiveSelected;
  chmod = pkgs.yaziPlugins.chmod;
  clipboard = pkgs.yaziPlugins.clipboard;
  close-and-restore-tab = {
    package = pkgs.yaziPlugins.close-and-restore-tab;
    setup = true;
  };
  confirm-quit = confirmQuit;
  copy-content = copyContent;
  diff = pkgs.yaziPlugins.diff;

  full-border = {
    package = pkgs.yaziPlugins.full-border;
    setup = true;
    settings.type = lib.generators.mkLuaInline "ui.Border.ROUNDED";
  };

  git = {
    package = pkgs.yaziPlugins.git;
    setup = true;
    settings.order = 1500;
  };
  git-actions = gitActions;

  lazygit = pkgs.yaziPlugins.lazygit;

  mediainfo = pkgs.yaziPlugins.mediainfo;
  mount = pkgs.yaziPlugins.mount;
  ouch = pkgs.yaziPlugins.ouch;
  piper = pkgs.yaziPlugins.piper;
  smart-enter = pkgs.yaziPlugins.smart-enter;
  smart-filter = pkgs.yaziPlugins.smart-filter;
  smart-paste = pkgs.yaziPlugins.smart-paste;
  smart-switch = smartSwitch;
  smart-tab = smartTab;
  symlink-status = {
    package = symlinkStatus;
    setup = true;
  };
  toggle-pane = pkgs.yaziPlugins.toggle-pane;
  vcs-files = pkgs.yaziPlugins.vcs-files;
}
