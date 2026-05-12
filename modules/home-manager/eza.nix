{ ... }:

{
  programs.eza = {
    enable = true;
    enableFishIntegration = true;

    # Command-line options of eza
    #
    # @see https://github.com/eza-community/eza#command-line-options
    extraOptions = [
      # Display options
      "--color=auto"
      "--color-scale=age"
      "--color-scale-mode=gradient"
      "--icons=auto"
      "--hyperlink"

      # Filtering options
      "--group-directories-first"

      # Long view options
      "--smart-group"
      "--header" 
      "--git"
      "--time-style=relative"
    ];
  };
}
