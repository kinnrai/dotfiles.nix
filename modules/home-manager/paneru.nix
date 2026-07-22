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
        window_focus_west = [ "alt - h" "alt - leftarrow" ];
        window_focus_east = [ "alt - l" "alt - rightarrow" ];
        window_focus_north = [ "alt - k" "alt - uparrow" ];
        window_focus_south = [ "alt - j" "alt - downarrow" ];

        window_swap_west = [ "alt + shift - h" "alt + shift - leftarrow" ];
        window_swap_east = [ "alt + shift - l" "alt + shift - rightarrow" ];
        window_swap_north = [ "alt + shift - k" "alt + shift - uparrow" ];
        window_swap_south = [ "alt + shift - j" "alt + shift - downarrow" ];

        window_virtualnum_1 = "alt - 1";
        window_virtualnum_2 = "alt - 2";
        window_virtualnum_3 = "alt - 3";
        window_virtualnum_4 = "alt - 4";
        window_virtualnum_5 = "alt - 5";
        window_virtualnum_6 = "alt - 6";
        window_virtualnum_7 = "alt - 7";
        window_virtualnum_8 = "alt - 8";
        window_virtualnum_9 = "alt - 9";
        window_virtualnum_10 = "alt - 0";

        window_virtualmovenum_1 = "alt + shift - 1";
        window_virtualmovenum_2 = "alt + shift - 2";
        window_virtualmovenum_3 = "alt + shift - 3";
        window_virtualmovenum_4 = "alt + shift - 4";
        window_virtualmovenum_5 = "alt + shift - 5";
        window_virtualmovenum_6 = "alt + shift - 6";
        window_virtualmovenum_7 = "alt + shift - 7";
        window_virtualmovenum_8 = "alt + shift - 8";
        window_virtualmovenum_9 = "alt + shift - 9";
        window_virtualmovenum_10 = "alt + shift - 0";

        window_center = "alt - c";
        window_resize = "alt - r";
        window_fullwidth = "alt - f";
        window_manage = "alt - t";
        window_stack = "alt - [";
        window_unstack = "alt - ]";
        window_togglefloatlayer = "alt - tab";
        quit = "alt + shift - q";
        restart = "alt + shift - r";
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
