{ pkgs, ... }:
{
  home.packages = [ pkgs.ghostty ];
  xdg.configFile."ghostty".source = ./config;
}
