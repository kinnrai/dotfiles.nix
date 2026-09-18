final: prev:

{
  sketchybar = prev.sketchybar.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./click-order.patch
    ];
  });
}
