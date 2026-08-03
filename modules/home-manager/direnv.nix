{ inputs, pkgs, ... }:

{
  imports = [ inputs.direnv-instant.homeModules.direnv-instant ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.global = {
      disable_stdin = true;
      hide_env_diff = true;
      load_dotenv = false;
    };
    # Based on direnv's documented human-readable cache layout:
    # https://github.com/direnv/direnv/wiki/Customizing-cache-location#human-readable-directories
    stdlib = ''
      direnv_layout_dir() {
        local cache_home project_dir hash path
        cache_home="''${XDG_CACHE_HOME:-$HOME/.cache}"
        # Resolve aliases such as /tmp and /private/tmp to the same layout.
        project_dir="$(pwd -P)"
        hash="$(printf '%s' "$project_dir" | ${pkgs.coreutils}/bin/sha256sum | ${pkgs.coreutils}/bin/cut -d ' ' -f 1)"
        path="''${project_dir//[^a-zA-Z0-9]/-}"
        printf '%s\n' "$cache_home/direnv/layouts/$hash$path"
      }
    '';
  };

  programs.direnv-instant.enable = true;
}
