{ ... }:

{
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    
    # replacing cd with zoxide
    options = [ "--cmd cd" ];
  };
}
