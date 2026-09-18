final: prev:

{
  sketchybar = prev.sketchybar.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./vertical-menu.patch
      ./click-order.patch
    ];
  });
}
