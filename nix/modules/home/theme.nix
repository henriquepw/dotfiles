{ config, pkgs, ... }:
{
  home.pointerCursor = {
    name = "breeze_cursors";
    package = pkgs.kdePackages.breeze;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

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
    font = {
      name = "JetBrainsMono Nerd Font Propo";
      size = 10;
    };
    # GTK icons only; Plasma icons come from plasma-manager
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme.override { color = "orange"; };
    };
    # Prefer dark variant without a heavy theme, avoiding light GTK dialogs in a dark setup
    gtk3.extraConfig."gtk-application-prefer-dark-theme" = true;
    gtk4.extraConfig."gtk-application-prefer-dark-theme" = true;
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
  };

  # Qt theming comes from Plasma itself (breeze/kdeglobals via plasma-manager); nothing to declare here
}
