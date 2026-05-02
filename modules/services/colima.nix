{ userHome, ... }:

{
  launchd.user.agents.colima = {
    serviceConfig = {
      KeepAlive = {
        SuccessfulExit = true;
      };
      RunAtLoad = true;
      ProgramArguments = [
        "/run/current-system/sw/bin/colima"
        "start"
        "-f"
      ];
      WorkingDirectory = userHome;
      StandardOutPath = "${userHome}/Library/Logs/colima.log";
      StandardErrorPath = "${userHome}/Library/Logs/colima.log";
    };

    environment = {
      COLIMA_HOME = "${userHome}/.config/colima";
      PATH = "/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin";
    };
  };
}
