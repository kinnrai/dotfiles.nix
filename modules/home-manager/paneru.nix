{ inputs, ... }:

{
  imports = [ inputs.paneru.homeModules.paneru ];

  services.paneru = {
    enable = true;

    settings = {
      options = {
        focus_follows_mouse = false;
        mouse_follows_focus = false;
        animation_speed = 12;
        mouse_resize_modifier = "alt";
      };

      swipe = {
        gesture.fingers_count = 4;
        scroll = {
          modifier = "cmd + ctrl";
          vertical_modifier = "alt";
        };
      };

      bindings = {
        window_focus_west = [ "cmd - h" "cmd - leftarrow" ];
        window_focus_east = [ "cmd - l" "cmd - rightarrow" ];
        window_focus_north = [ "cmd - k" "cmd - uparrow" ];
        window_focus_south = [ "cmd - j" "cmd - downarrow" ];

        window_swap_west = [ "cmd + ctrl - h" "cmd + ctrl - leftarrow" ];
        window_swap_east = [ "cmd + ctrl - l" "cmd + ctrl - rightarrow" ];
        window_swap_north = [ "cmd + ctrl - k" "cmd + ctrl - uparrow" ];
        window_swap_south = [ "cmd + ctrl - j" "cmd + ctrl - downarrow" ];

        window_virtualnum_1 = "cmd - 1";
        window_virtualnum_2 = "cmd - 2";
        window_virtualnum_3 = "cmd - 3";
        window_virtualnum_4 = "cmd - 4";
        window_virtualnum_5 = "cmd - 5";
        window_virtualnum_6 = "cmd - 6";
        window_virtualnum_7 = "cmd - 7";
        window_virtualnum_8 = "cmd - 8";
        window_virtualnum_9 = "cmd - 9";
        window_virtualnum_10 = "cmd - 0";

        window_virtualmovenum_1 = "cmd + ctrl - 1";
        window_virtualmovenum_2 = "cmd + ctrl - 2";
        window_virtualmovenum_3 = "cmd + ctrl - 3";
        window_virtualmovenum_4 = "cmd + ctrl - 4";
        window_virtualmovenum_5 = "cmd + ctrl - 5";
        window_virtualmovenum_6 = "cmd + ctrl - 6";
        window_virtualmovenum_7 = "cmd + ctrl - 7";
        window_virtualmovenum_8 = "cmd + ctrl - 8";
        window_virtualmovenum_9 = "cmd + ctrl - 9";
        window_virtualmovenum_10 = "cmd + ctrl - 0";

        window_center = "alt - c";
        window_resize = "alt - r";
        window_fullwidth = "alt - f";
        window_manage = "alt - t";
        window_stack = "alt - [";
        window_unstack = "alt - ]";
        window_togglefloatlayer = "alt - tab";
        quit = "cmd + ctrl + shift - q";
        restart = "cmd + ctrl + shift - r";
      };

      windows = {
        pip = {
          title = "Picture.*(in)?.*[Pp]icture";
          floating = true;
        };
        cleanshotx = {
          title = ".*";
          bundle_id = "pl.maketheweb.cleanshotx";
          floating = true;
        };
        all = {
          title = ".*";
          horizontal_padding = 4;
          vertical_padding = 2;
          grid = "5:5:1:1:3:3";
        };
      };
    };
  };
}
