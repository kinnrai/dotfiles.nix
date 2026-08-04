{ inputs, ... }:

{
  imports = [ inputs.paneru.homeModules.paneru ];

  services.paneru = {
    enable = true;

    settings = {
      options = {
        focus_follows_mouse = false;
        mouse_follows_focus = false;
        preset_column_widths = [ 0.25 0.33 0.5 0.66 0.75 ];
        animation_speed = 12;
      };

      swipe.gesture.fingers_count = 4;

      bindings = {
        window_focus_west = "alt - h";
        window_focus_east = "alt - l";
        window_focus_north = "alt - k";
        window_focus_south = "alt - j";

        window_swap_west = "alt + shift - h";
        window_swap_east = "alt + shift - l";
        window_swap_north = "alt + shift - k";
        window_swap_south = "alt + shift - j";

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

        window_center = "alt + shift - c";
        window_resize = "alt + shift - r";
        window_fullwidth = "alt + shift - f";
        window_manage = "alt + shift - t";
        window_stack = "alt + shift - [";
        window_unstack = "alt + shift - ]";
        window_togglefloatlayer = "alt - tab";
        quit = "ctrl + alt + cmd - q";
        restart = "ctrl + alt + cmd - r";
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
