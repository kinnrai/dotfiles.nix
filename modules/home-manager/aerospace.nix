{ config, ... }:

{
  programs.aerospace = {
    enable = true;

    launchd.enable = true;

    settings = {
      config-version = 2;

      exec.env-vars.PATH = builtins.concatStringsSep ":" [
        "${config.home.profileDirectory}/bin"
        "/run/current-system/sw/bin"
        "/opt/homebrew/bin"
        "/opt/homebrew/sbin"
        "\${PATH}"
      ];

      after-startup-command = [ "exec-and-forget sketchybar" ];

      on-mode-changed = [
        ''
          exec-and-forget /bin/bash -lc '
          mode="$(aerospace list-modes --current 2>/dev/null)"

          sketchybar --trigger aerospace_mode_change \
            MODE="$mode"
          '
        ''
      ];

      on-focus-changed = [
        ''
          exec-and-forget /bin/bash -lc '
          workspace="$(aerospace list-workspaces --focused 2>/dev/null)"
          window_id="$(aerospace list-windows --focused --format "%{window-id}" 2>/dev/null)"
          app="$(aerospace list-windows --focused --format "%{app-name}" 2>/dev/null)"

          sketchybar --trigger aerospace_focus_change \
            FOCUSED_WORKSPACE="$workspace" \
            FOCUSED_WINDOW_ID="$window_id" \
            FOCUSED_APP="$app"
          '
        ''
      ];

      on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];

      enable-normalization-flatten-containers = false;

      persistent-workspaces = [
        "1"
        "2"
        "3"
        "4"
        "5"
        "6"
        "7"
        "8"
        "9"
        "10"
      ];

      gaps = {
        inner.horizontal = 10;
        inner.vertical = 10;
        outer.left = 8;
        outer.bottom = 8;
        outer.top = [
          { monitor.main = 8; }
          40
        ];
        outer.right = 8;
      };

      mode = {
        main.binding = {
          alt-slash = "layout tiles horizontal vertical";
          alt-comma = "layout accordion horizontal vertical";

          alt-h = "focus left";
          alt-j = "focus down";
          alt-k = "focus up";
          alt-l = "focus right";

          alt-left = "focus left";
          alt-down = "focus down";
          alt-up = "focus up";
          alt-right = "focus right";

          alt-shift-h = "move left";
          alt-shift-j = "move down";
          alt-shift-k = "move up";
          alt-shift-l = "move right";

          alt-shift-left = "move left";
          alt-shift-down = "move down";
          alt-shift-up = "move up";
          alt-shift-right = "move right";

          alt-g = "split horizontal";
          alt-v = "split vertical";

          alt-minus = "resize smart -50";
          alt-equal = "resize smart +50";

          alt-f = "fullscreen";
          alt-shift-f = "macos-native-fullscreen";

          alt-1 = "workspace 1";
          alt-2 = "workspace 2";
          alt-3 = "workspace 3";
          alt-4 = "workspace 4";
          alt-5 = "workspace 5";
          alt-6 = "workspace 6";
          alt-7 = "workspace 7";
          alt-8 = "workspace 8";
          alt-9 = "workspace 9";
          alt-0 = "workspace 10";

          alt-shift-1 = "move-node-to-workspace --focus-follows-window 1";
          alt-shift-2 = "move-node-to-workspace --focus-follows-window 2";
          alt-shift-3 = "move-node-to-workspace --focus-follows-window 3";
          alt-shift-4 = "move-node-to-workspace --focus-follows-window 4";
          alt-shift-5 = "move-node-to-workspace --focus-follows-window 5";
          alt-shift-6 = "move-node-to-workspace --focus-follows-window 6";
          alt-shift-7 = "move-node-to-workspace --focus-follows-window 7";
          alt-shift-8 = "move-node-to-workspace --focus-follows-window 8";
          alt-shift-9 = "move-node-to-workspace --focus-follows-window 9";
          alt-shift-0 = "move-node-to-workspace --focus-follows-window 10";

          alt-tab = "workspace-back-and-forth";
          alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

          alt-shift-semicolon = "mode service";
          alt-r = "mode resize";
        };

        resize.binding = {
          esc = [
            "reload-config"
            "mode main"
          ];
          enter = [
            "reload-config"
            "mode main"
          ];

          minus = "resize smart -50";
          equal = "resize smart +50";

          h = "resize width -25";
          j = "resize height +25";
          k = "resize height -25";
          l = "resize width +25";
        };

        service.binding = {
          esc = [
            "reload-config"
            "mode main"
          ];
          enter = [
            "reload-config"
            "mode main"
          ];

          r = [
            "flatten-workspace-tree"
            "mode main"
          ];
          f = [
            "layout floating tiling"
            "mode main"
          ];
          backspace = [
            "close-all-windows-but-current"
            "mode main"
          ];

          alt-shift-h = [
            "join-with left"
            "mode main"
          ];
          alt-shift-j = [
            "join-with down"
            "mode main"
          ];
          alt-shift-k = [
            "join-with up"
            "mode main"
          ];
          alt-shift-l = [
            "join-with right"
            "mode main"
          ];
        };
      };

      on-window-detected = [
        {
          "if".app-id = "com.parallels.desktop.console";
          run = "move-node-to-workspace 10";
        }
      ];
    };
  };
}
