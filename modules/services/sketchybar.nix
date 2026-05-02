{ pkgs, userHome, ... }:

{
  launchd.user.agents.sketchybar = {
    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
      ProcessType = "Interactive";
      ProgramArguments = [
        "${pkgs.sketchybar}/bin/sketchybar"
      ];
      StandardOutPath = "${userHome}/Library/Logs/sketchybar.out.log";
      StandardErrorPath = "${userHome}/Library/Logs/sketchybar.err.log";
    };

    environment = {
      LANG = "en_US.UTF-8";
      PATH = "/opt/homebrew/bin:/opt/homebrew/sbin:/usr/bin:/bin:/usr/sbin:/sbin";
    };
  };
}
