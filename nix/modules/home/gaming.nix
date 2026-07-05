{
  pkgs,
  config,
  dotfiles,
  ...
}:
{
  home.packages = with pkgs; [
    sunshine
    faugus-launcher
    protonup-qt
    mangohud
  ];

  # Symlink pro repo — credentials/ é gravado pelo sunshine e ignorado no git
  xdg.configFile."sunshine".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/sunshine";

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

  # Sunshine autostart as systemd user service
  systemd.user.services.sunshine = {
    Unit = {
      Description = "Sunshine game streaming server";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.sunshine}/bin/sunshine";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
