{ inputs, lib, ... }:

let
  pluginDefs = [
    {
      name = "async-prompt";
      src = inputs.fish-async-prompt;
    }
    {
      name = "magic-enter";
      src = inputs.fish-magic-enter;
    }
    {
      name = "puffer";
      src = inputs.fish-puffer;
    }
  ];

  hmPlugins = map (plugin: builtins.removeAttrs plugin [ "settings" ]) pluginDefs;

  pluginOptionsText =
    lib.concatStringsSep "\n\n" (
      lib.filter (chunk: chunk != "") (
        map (
          plugin:
          let
            options = plugin.settings or { };
          in
          if options == { } then
            ""
          else
            lib.concatLines (
              [ "# ${plugin.name}" ]
              ++ lib.mapAttrsToList (name: value: "set -g ${name} ${lib.escapeShellArg value}") options
            )
        ) pluginDefs
      )
    );
in
{
  programs.fish.plugins = hmPlugins;

  xdg.configFile = lib.mkMerge [
    {
      # Keep plugin-owned settings in an early conf.d file instead of
      # programs.fish.interactiveShellInit. Fish loads conf.d before config.fish,
      # and Home Manager implements plugins as conf.d/plugin-<name>.fish loaders.
      # That lets plugin init code see these variables on startup.
      #
      # @see https://fishshell.com/docs/current/language.html#configuration-files
      "fish/conf.d/00-plugin-options.fish".text = pluginOptionsText;
    }
  ];
}
