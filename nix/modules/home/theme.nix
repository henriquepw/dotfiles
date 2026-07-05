{ ... }:
{
  stylix.targets = {
    # Reintroduziria Kvantum/qtct — o Plasma 6 já tematiza Qt nativamente
    qt.enable = false;
    # O nvim tem config própria (ashen) via symlink out-of-store
    neovim.enable = false;
  };
}
