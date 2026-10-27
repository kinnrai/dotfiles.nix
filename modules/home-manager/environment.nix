{ userHome, ... }:

{
  home.language.base = "zh_CN.UTF-8";

  home.sessionVariables = {
    ANDROID_HOME = "${userHome}/Library/Android/sdk";
    SSH_AUTH_SOCK = "${userHome}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
    MAS_NO_AUTO_INDEX = "1";
    EDITOR = "nvim";
  };

  home.sessionPath = [
    "${userHome}/Library/Android/sdk/platform-tools"
  ];
}
