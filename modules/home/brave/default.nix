{ pkgs, ... }:
{
  home.packages = [ pkgs.brave ];
  xdg.configFile."brave-flags.conf".source = ./brave-flags.conf;
  xdg.configFile."brave-origin-beta-flags.conf".source = ./brave-origin-beta-flags.conf;
}
