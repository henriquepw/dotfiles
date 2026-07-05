{ pkgs, ... }:
{
  stylix = {
    enable = true;
    polarity = "dark";

    # Matte Black — fundo escuro com destaques em laranja
    # base0D é o slot de accent (seleção/DecorationFocus no KDE, accent no GTK)
    base16Scheme = {
      scheme = "Matte Black";
      base00 = "121212";
      base01 = "1a1a1a";
      base02 = "333333";
      base03 = "8a8a8d";
      base04 = "8a8a8d";
      base05 = "bebebe";
      base06 = "eaeaea";
      base07 = "ffffff";
      base08 = "d35f5f";
      base09 = "e68e0d";
      base0A = "ffc107";
      base0B = "ffd76d";
      base0C = "eaeaea";
      base0D = "f59e0b";
      base0E = "e68e0d";
      base0F = "b91c1c";
    };

    # image não definido — wallpaper continua com o plasma-manager (kde.nix)

    fonts = {
      monospace = {
        name = "JetBrainsMono Nerd Font Mono";
        package = pkgs.nerd-fonts.jetbrains-mono;
      };
      sansSerif = {
        name = "JetBrainsMono Nerd Font Propo";
        package = pkgs.nerd-fonts.jetbrains-mono;
      };
      serif = {
        name = "JetBrainsMono Nerd Font Propo";
        package = pkgs.nerd-fonts.jetbrains-mono;
      };
      emoji = {
        name = "Noto Color Emoji";
        package = pkgs.noto-fonts-color-emoji;
      };
      sizes = {
        desktop = 10;
        applications = 10;
        terminal = 14;
        popups = 9;
      };
    };

    cursor = {
      name = "breeze_cursors";
      package = pkgs.kdePackages.breeze;
      size = 24;
    };

    # Só cobre GTK — os ícones do Plasma vêm do plasma-manager (kde.nix)
    icons = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
    };
  };
}
