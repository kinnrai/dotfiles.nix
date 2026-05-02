{ pkgs, userHome, ... }:

{
  launchd.daemons.mihomo = {
    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
      ProgramArguments = [
        "${pkgs.mihomo}/bin/mihomo"
        "-d"
        "${userHome}/.config/mihomo"
      ];
      WorkingDirectory = "${userHome}/.config/mihomo";
      StandardOutPath = "/Library/Logs/mihomo.log";
      StandardErrorPath = "/Library/Logs/mihomo.log";
    };
  };
}
