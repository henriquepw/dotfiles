{
  pkgs,
  config,
  dotfiles,
  ...
}:
let
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  home.packages = with pkgs; [
    faugus-launcher
    protonup-qt
    mangohud
  ];

  # Symlink pro repo — credentials/ é gravado pelo sunshine e ignorado no git
  xdg.configFile."sunshine".source = link "${dotfiles}/sunshine";

  # Steam autostart (silent, no window on boot)
  xdg.configFile."autostart/steam.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Steam
    Exec=steam -silent %U
    Icon=steam
    Comment=Steam Game Launcher
    X-KDE-autostart-after=panel
  '';
}
