{ pkgs, ... }:
{
  home.packages = with pkgs; [
    zsh
    starship
    zoxide
    fzf
  ];
  home.file.".zshrc".source = ./.zshrc;
  xdg.configFile."starship.toml".source = ./starship.toml;
  xdg.configFile."xdg-terminals.list".source = ./xdg-terminals.list;
}
