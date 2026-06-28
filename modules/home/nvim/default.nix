{ pkgs, ... }:
{
  home.packages = with pkgs; [
    neovim
    nil
    nixfmt-rfc-style
    statix
  ];
  xdg.configFile."nvim".source = ./config;
}
