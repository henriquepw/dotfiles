{ pkgs, ... }:
{
  home.packages = with pkgs; [
    neovim
    nil
    nixfmt
    statix
  ];
  xdg.configFile."nvim".source = ./config;
}
