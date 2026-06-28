{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    kdePackages.krohnkite
    kdePackages.qtstyleplugin-kvantum
  ];

  # Clones and installs on first run; skips on subsequent activations
  home.activation.monochrome-kde = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    _MONO="$HOME/.local/share/monochrome-kde"
    if [ ! -f "$_MONO/.installed" ]; then
      ${pkgs.git}/bin/git clone --depth=1 https://github.com/pwyde/monochrome-kde.git "$_MONO" || true
      ${pkgs.bash}/bin/bash "$_MONO/install.sh" --install || true
      touch "$_MONO/.installed"
    fi
  '';

  xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
    [General]
    theme=MonochromeSolid
  '';

  programs.plasma = {
    enable = true;

    workspace = {
      lookAndFeel = "Monochrome";
      colorScheme = "BreezeDark";
      cursor = {
        theme = "breeze_cursors";
        size = 24;
      };
    };

    fonts = {
      general = {
        family = "JetBrainsMono Nerd Font Propo";
        pointSize = 10;
      };
      fixedWidth = {
        family = "JetBrainsMono Nerd Font Propo";
        pointSize = 10;
      };
      small = {
        family = "JetBrainsMono Nerd Font Propo";
        pointSize = 8;
      };
      toolbar = {
        family = "JetBrainsMono Nerd Font Propo";
        pointSize = 9;
      };
      menu = {
        family = "JetBrainsMono Nerd Font Propo";
        pointSize = 10;
      };
      windowTitle = {
        family = "JetBrainsMono Nerd Font Propo";
        pointSize = 10;
      };
    };

    kwin = {
      virtualDesktops = {
        number = 6;
        rows = 1;
      };
    };

    # Accent color (orange) + Kvantum style + Krohnkite tiling plugin
    configFile = {
      "kdeglobals"."General"."AccentColor".value = "233,100,58";
      "kdeglobals"."KDE"."widgetStyle".value = "kvantum-dark";
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

  xdg.configFile."autostart/vicinae.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Vicinae
    Exec=${pkgs.vicinae}/bin/vicinae
    Icon=vicinae
    X-KDE-autostart-after=panel
  '';
}
