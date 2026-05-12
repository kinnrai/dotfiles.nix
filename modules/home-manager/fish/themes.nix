{ inputs, lib, ... }:

let
  # Set to null to install theme files without selecting one at shell startup.
  activeTheme = "catppuccin-macchiato";

  themeDefs = [];

  installedThemes = lib.foldl' (
    acc: theme:
    acc
    // lib.mapAttrs' (fileName: _: {
      name = "fish/themes/${fileName}";
      value.source = "${theme.src}/themes/${fileName}";
    }) (
      lib.filterAttrs (
        fileName: type: type == "regular" && lib.hasSuffix ".theme" fileName
      ) (builtins.readDir "${theme.src}/themes")
    )
  ) { } themeDefs;
in
{
  # Keep fish themes separate from programs.fish.plugins. Home Manager's fish
  # plugin support wires in functions/, completions/, conf.d/, init.fish, and
  # key_bindings.fish, but it does not install a plugin's themes/ directory
  # into ~/.config/fish/themes. We link theme files ourselves so
  # `fish_config theme list/choose` can see them like native fish themes.
  xdg.configFile = lib.mkMerge [
    installedThemes
    (lib.mkIf (activeTheme != null) {
      # Install theme files declaratively, but keep the active theme as one
      # explicit choice. This avoids persisting fish_color_* universal
      # variables via `fish_config theme save`, while still letting us install
      # themes from multiple upstream sources. Set activeTheme = null to skip
      # generating this file and only install the available theme files.
      "fish/conf.d/01-theme.fish".text = ''
        if status is-interactive
          fish_config theme choose ${lib.escapeShellArg activeTheme} >/dev/null
        end
      '';
    })
  ];
}
