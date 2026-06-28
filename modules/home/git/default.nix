{ pkgs, ... }:
{
  home.packages = with pkgs; [
    git
    lazygit
  ];
  xdg.configFile."git".source = ./config;
}
