{
  pkgs,
  config,
  dotfiles,
  ...
}:
let
  link = config.lib.file.mkOutOfStoreSymlink;

  # Ícones de tray do sunshine no estilo dos ícones de painel do Papirus
  # (#dfdfdf, mesma cor que o Hardcode-Tray instalaria — Papirus não tem ícone
  # pro sunshine, então recolorimos o oficial). ~/.local/share/icons tem
  # precedência sobre o hicolor do sistema na resolução por nome.
  sunshineTrayIcons = pkgs.runCommand "sunshine-papirus-tray-icons" { } ''
    mkdir -p $out
    for f in ${pkgs.sunshine}/share/icons/hicolor/scalable/status/*.svg; do
      sed 's/fill:#[0-9A-Fa-f]\{6\}/fill:#dfdfdf/g' "$f" > "$out/$(basename "$f")"
    done
  '';
in
{
  home.packages = with pkgs; [
    faugus-launcher
    protonup-qt
    mangohud
    kdePackages.krfb # krfb-virtualmonitor — display virtual p/ o app "Steam V" do Sunshine
  ];

  # Symlink pro repo — credentials/ é gravado pelo sunshine e ignorado no git
  xdg.configFile."sunshine".source = link "${dotfiles}/sunshine";

  xdg.dataFile = builtins.listToAttrs (
    map
      (name: {
        name = "icons/hicolor/scalable/status/dev.lizardbyte.app.Sunshine-${name}.svg";
        value.source = "${sunshineTrayIcons}/dev.lizardbyte.app.Sunshine-${name}.svg";
      })
      [
        "tray"
        "playing"
        "pausing"
        "locked"
      ]
  );

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
