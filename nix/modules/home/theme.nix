{ config, pkgs, ... }:
{
  # Fallbacks nix que substituem cada função do stylix (removido — veredito A do
  # mapa noctalia-shell). O Noctalia NÃO tema GTK/Qt (templates opt-in ficam off,
  # builtin_ids = []), então fica confinado a ~/.config/noctalia/ — a cor GTK vem
  # daqui (nix), fonte única, sem briga de gtk.css.

  # cursor (substitui stylix.cursor)
  home.pointerCursor = {
    name = "breeze_cursors";
    package = pkgs.kdePackages.breeze;
    size = 24;
    gtk.enable = true;
    x11.enable = true; # XWayland
  };

  # fontes de sistema (substitui stylix.fonts). Os pacotes já vêm do host
  # (fonts.packages em hosts/citadel/default.nix); aqui só os defaults do fontconfig.
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font Mono" ];
      sansSerif = [ "JetBrainsMono Nerd Font Propo" ];
      serif = [ "JetBrainsMono Nerd Font Propo" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  gtk = {
    enable = true;
    # fonte GTK explícita (stylix punha via gtk)
    font = {
      name = "JetBrainsMono Nerd Font Propo";
      size = 10;
    };
    # ícones GTK (substitui stylix.icons; só GTK — os do Plasma vêm do plasma-manager)
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme.override { color = "orange"; };
    };
    # Preferir variante escura sem escolher tema pesado — evita diálogos GTK claros
    # num setup dark (libadwaita/Adwaita honram este hint)
    gtk3.extraConfig."gtk-application-prefer-dark-theme" = true;
    gtk4.extraConfig."gtk-application-prefer-dark-theme" = true;
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
  };

  # Qt/Plasma: o tema Qt dos apps vem do próprio Plasma (breeze/kdeglobals via
  # plasma-manager). stylix já tinha qt.enable=false; nada a declarar aqui.
  # console/TTY: omitido neste host (streaming/Plasma; não é um gap).
}
