{ config, userHome, ... }:

{
  home.language.base = "zh_CN.UTF-8";

  home.sessionVariables = {
    ANDROID_HOME = "${userHome}/Library/Android/sdk";
    SSH_AUTH_SOCK = "${userHome}/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock";
    MAS_NO_AUTO_INDEX = "1";
    EDITOR = "nvim";
  };

  home.sessionPath = [
    "${userHome}/Library/Android/sdk/platform-tools"
    "${config.xdg.dataHome}/cargo/bin"
    "${userHome}/.pub-cache/bin"
    "${config.xdg.dataHome}/go/bin"
  ];
}
