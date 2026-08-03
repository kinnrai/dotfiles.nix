{ ... }:

{
  programs.zoxide = {
    enable = true;

    # replacing cd with zoxide
    options = [ "--cmd cd" ];
  };
}
