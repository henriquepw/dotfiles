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

    # us-intl com dead keys — sem isso o KDE fica no 'us' puro e nenhum
    # acento funciona; o XCompose acima só troca ć→ç por cima disso
    input.keyboard.layouts = [
      {
        layout = "us";
        variant = "intl";
      }
    ];

    kwin = {
      virtualDesktops = {
        number = 6;
        rows = 1;
      };
    };

    # Mesma imagem do desktop no lock screen
    kscreenlocker.appearance.wallpaper = "${dotfiles}/wallpaper.png";

    configFile = {
      # UI em inglês — o plasma-localerc sobrescreve o LANG da sessão, então
      # precisa ficar coerente com o i18n do sistema (formatos pt-BR via LC_*)
      "plasma-localerc"."Translations"."LANGUAGE".value = "en_US:pt_BR";
      # KWallet desligado (cofre de segredos; não tem relação com o lock de tela)
      "kwalletrc"."Wallet"."Enabled".value = false;
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
      "services/vicinae.desktop"."toggle" = "Meta+Return";

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
        # Krohnkite — libera Meta+Return pro vicinae
        "KrohnkiteSetMaster" = "none";
        # Krohnkite — layouts
        "KrohnkiteToggleFloat" = "Meta+F";
        "KrohnkiteFloatAll" = "Meta+Shift+F";
        "KrohnkiteMonocleLayout" = "Meta+M";
      };
    };
  };

  # kwalletmanager não é removível via plasma6.excludePackages (está nos
  # requiredPackages do módulo) — esconde do menu por cima
  xdg.dataFile = {
    "applications/org.kde.kwalletmanager.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=KWalletManager
      NoDisplay=true
      Hidden=true
    '';
    "applications/kwalletmanager5-kwalletd.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=KWalletManager
      NoDisplay=true
      Hidden=true
    '';
  };

  # Módulo do flake do vicinae — assim o target vicinae do stylix aplica o tema
  programs.vicinae = {
    enable = true;
    package = pkgs.vicinae;
    systemd = {
      enable = true;
      autoStart = true;
    };
  };
}
