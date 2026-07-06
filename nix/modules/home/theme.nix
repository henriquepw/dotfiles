{ config, ... }:
{
  # O KDE recria ~/.gtkrc-2.0 por fora do home-manager, gerando conflito de
  # backup a cada switch — gerencia o gtkrc no XDG path e aponta via env var
  gtk.gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";

  stylix.targets = {
    # Reintroduziria Kvantum/qtct — o Plasma 6 já tematiza Qt nativamente
    qt.enable = false;
    # O nvim tem config própria (ashen) via symlink out-of-store
    neovim.enable = false;
  };
}
