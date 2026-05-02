{ pkgs, userHome, ... }:

{
  launchd.user.agents.apfel = {
    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
      ProgramArguments = [
        "${pkgs.apfel-llm}/bin/apfel"
        "--serve"
      ];
      StandardOutPath = "${userHome}/Library/Logs/apfel.log";
      StandardErrorPath = "${userHome}/Library/Logs/apfel.log";
    };
  };
}
