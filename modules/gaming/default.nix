{
  pkgs,
  config,
  repoRoot,
  ...
}:
let
  link = config.lib.file.mkOutOfStoreSymlink;

  sunshineTrayIcons = pkgs.runCommand "sunshine-papirus-tray-icons" { } ''
    mkdir -p $out
    for f in ${pkgs.sunshine}/share/icons/hicolor/scalable/status/*.svg; do
      sed 's/fill:#[0-9A-Fa-f]\{6\}/fill:#dfdfdf/g' "$f" > "$out/$(basename "$f")"
    done
  '';
in
{
  home.packages = with pkgs; [
    discord
    faugus-launcher
    lutris
    protonup-qt
    mangohud
    kdePackages.krfb
  ];

  xdg.configFile."sunshine".source = link "${repoRoot}/modules/gaming/config/sunshine";

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
