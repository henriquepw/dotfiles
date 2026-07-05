{
  pkgs,
  lib,
  config,
  dotfiles,
  ...
}:
let
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  home.packages = with pkgs; [
    kdePackages.krohnkite
  ];

  # 'c deve gerar ç, não ć
  home.file.".XCompose".source = link "${dotfiles}/kde/XCompose";

  # Panel layout — copied once so KDE can mutate it freely
  home.activation.plasma-panel = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    _PANEL="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
    if [ ! -f "$_PANEL" ]; then
      cp "${dotfiles}/kde/plasma-org.kde.plasma.desktop-appletsrc" "$_PANEL"
      chmod 644 "$_PANEL"
    fi
  '';

  programs.plasma = {
    enable = true;

    # Cores, fontes, cursor e GTK vêm do stylix (hosts/citadel/theme.nix)
    workspace = {
      iconTheme = "Papirus-Dark";
      wallpaper = "${dotfiles}/wallpaper.png";
    };

    kwin = {
      virtualDesktops = {
        number = 6;
        rows = 1;
      };
    };

    configFile = {
      "kwinrc"."Plugins"."slideEnabled".value = false;
      "kwinrc"."Plugins"."krohnkiteEnabled".value = true;
      "kwinrc"."Script-krohnkite"."noTileBorder".value = true;
      "kwinrc"."Script-krohnkite"."screenGapBetween".value = 8;
      "kwinrc"."Script-krohnkite"."screenGapBottom".value = 8;
      "kwinrc"."Script-krohnkite"."screenGapLeft".value = 8;
      "kwinrc"."Script-krohnkite"."screenGapRight".value = 8;
      "kwinrc"."Script-krohnkite"."screenGapTop".value = 8;
      "kwinrc"."Script-krohnkite"."floatingLayoutOrder".value = 2;
    };

    shortcuts = {
      "services/vicinae.desktop"."toggle" = "Meta+Space";

      kwin = {
        # Desktop switching — QWERTY row
        "Switch to Desktop 1" = "Meta+Q";
        "Switch to Desktop 2" = "Meta+W";
        "Switch to Desktop 3" = "Meta+E";
        "Switch to Desktop 4" = "Meta+R";
        "Switch to Desktop 5" = "Meta+T";
        "Switch to Desktop 6" = "Meta+Y";
        # Move window to desktop — number row
        "Window to Desktop 1" = "Meta+1";
        "Window to Desktop 2" = "Meta+2";
        "Window to Desktop 3" = "Meta+3";
        "Window to Desktop 4" = "Meta+4";
        "Window to Desktop 5" = "Meta+5";
        "Window to Desktop 6" = "Meta+6";
        # Window actions
        "Window Close" = "Meta+Shift+W";
        "Window Restore" = "Meta+Backspace";
        "Window to Next Screen" = "Meta+Shift+Right";
        "Window to Previous Screen" = "Meta+Shift+Left";
        # Krohnkite — focus (vim-style)
        "KrohnkiteFocusLeft" = "Meta+H";
        "KrohnkiteFocusDown" = "Meta+J";
        "KrohnkiteFocusUp" = "Meta+K";
        "KrohnkiteFocusRight" = "Meta+L";
        # Krohnkite — move window
        "KrohnkiteShiftLeft" = "Meta+Shift+H";
        "KrohnkiteShiftDown" = "Meta+Shift+J";
        "KrohnkiteShiftUp" = "Meta+Shift+K";
        "KrohnkiteShiftRight" = "Meta+Shift+L";
        # Krohnkite — resize
        "KrohnkiteShrinkWidth" = "Meta+Ctrl+H";
        "KrohnkiteGrowHeight" = "Meta+Ctrl+J";
        "KrohnkiteShrinkHeight" = "Meta+Ctrl+K";
        "KrohnkitegrowWidth" = "Meta+Ctrl+L";
        # Krohnkite — layouts
        "KrohnkiteToggleFloat" = "Meta+F";
        "KrohnkiteFloatAll" = "Meta+Shift+F";
        "KrohnkiteMonocleLayout" = "Meta+M";
      };
    };
  };

  systemd.user.services.vicinae = {
    Unit = {
      Description = "Vicinae launcher daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.vicinae}/bin/vicinae";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
