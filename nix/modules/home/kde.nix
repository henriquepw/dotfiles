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

  # 'c should produce ç, not ć
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

    # Cursor/fonts/GTK icons come from nix fallbacks (modules/home/theme.nix);
    # Plasma icon theme + frame colors are set here (stylix removido — veredito A)
    workspace = {
      iconTheme = "Papirus-Dark";
      wallpaper = "${dotfiles}/wallpaper.png";
    };

    # us-intl dead keys — without this KDE stays plain 'us' and accents don't work
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

    # Same wallpaper on the lock screen
    kscreenlocker.appearance.wallpaper = "${dotfiles}/wallpaper.png";

    # Streaming box: never blank/dim/suspend, else the (virtual) display goes black
    powerdevil.AC = {
      autoSuspend.action = "nothing";
      dimDisplay.enable = false;
      turnOffDisplay.idleTimeout = "never";
    };

    configFile = {
      # UI in English; keep coherent with system i18n (pt-BR formats via LC_*)
      "plasma-localerc"."Translations"."LANGUAGE".value = "en_US:pt_BR";
      # KWallet off (secrets vault; unrelated to screen lock)
      "kwalletrc"."Wallet"."Enabled".value = false;
      "kwinrc"."Plugins"."slideEnabled".value = false;
      "kwinrc"."Plugins"."krohnkiteEnabled".value = false;
      "kwinrc"."Script-krohnkite"."noTileBorder".value = true;
      "kwinrc"."Script-krohnkite"."screenGapBetween".value = 8;
      "kwinrc"."Script-krohnkite"."screenGapBottom".value = 8;
      "kwinrc"."Script-krohnkite"."screenGapLeft".value = 8;
      "kwinrc"."Script-krohnkite"."screenGapRight".value = 8;
      "kwinrc"."Script-krohnkite"."screenGapTop".value = 8;
      "kwinrc"."Script-krohnkite"."floatingLayoutOrder".value = 2;
      # Steam/Proton games are steam_app_<id>; [substring] makes krohnkite ignore them (list = krohnkite 0.9.9.2 defaults + [steam_app])
      "kwinrc"."Script-krohnkite"."ignoreClass".value =
        "krunner,yakuake,spectacle,kded5,xwaylandvideobridge,plasmashell,ksplashqml,org.kde.plasmashell,org.kde.polkit-kde-authentication-agent-1,org.kde.kruler,kruler,kwin_wayland,ksmserver-logout-greeter,[steam_app]";

      # Moldura (R4): Breeze com borda fina só no foco, sem barra de título/botões,
      # sem sombra. NÃO usar noborder (tiraria título e borda juntos).
      "kwinrc"."org.kde.kdecoration2"."library".value = "org.kde.breeze";
      "kwinrc"."org.kde.kdecoration2"."theme".value = "Breeze";
      "kwinrc"."org.kde.kdecoration2"."BorderSize".value = "Tiny";
      "kwinrc"."org.kde.kdecoration2"."BorderSizeAuto".value = false;
      "kwinrc"."org.kde.kdecoration2"."ButtonsOnLeft".value = "";
      "kwinrc"."org.kde.kdecoration2"."ButtonsOnRight".value = "";

      # Sem sombra (decoração Breeze + efeito do compositor)
      "kwinrc"."Plugins"."kwin4_effect_shadowEnabled".value = false;
      "breezerc"."Common"."ShadowSize".value = "ShadowNone";
      "breezerc"."Common"."ShadowStrength".value = 0;
      "breezerc"."Common"."OutlineIntensity".value = "OutlineOff";

      # Cor da moldura (Breeze pinta a borda na cor da barra de título, resolvida
      # por estado ativo/inativo do color scheme). Antes vinha do stylix base0D;
      # com stylix fora, setar explícito: foco = accent f59e0b, sem foco = fundo
      # base00 121212 (borda "some" fora do foco). Valores kdeglobals = R,G,B.
      "kdeglobals"."WM"."activeBackground".value = "245,158,11";
      "kdeglobals"."WM"."activeForeground".value = "18,18,18";
      "kdeglobals"."WM"."inactiveBackground".value = "18,18,18";
      "kdeglobals"."WM"."inactiveForeground".value = "138,138,141";
      "kdeglobals"."WM"."frame".value = "245,158,11";
      "kdeglobals"."WM"."inactiveFrame".value = "18,18,18";
    };

    # Per-app placement (initially = place on open, still movable); Desktop_N is the stable virtual-desktop id
    window-rules = [
      # match-whole=false matches only resourceClass (true compares "name class" and never hits)
      {
        description = "Terminal foot → painel 1";
        match.window-class = {
          value = "foot";
          type = "exact";
          match-whole = false;
        };
        apply.desktops = {
          value = "Desktop_1";
          apply = "initially";
        };
      }
      {
        description = "Navegador Brave → painel 2";
        match.window-class = {
          value = "brave-browser";
          type = "exact";
          match-whole = false;
        };
        apply.desktops = {
          value = "Desktop_2";
          apply = "initially";
        };
      }
      {
        description = "Cliente Steam → painel 5";
        match.window-class = {
          value = "steam";
          type = "exact";
          match-whole = false;
        };
        apply.desktops = {
          value = "Desktop_5";
          apply = "initially";
        };
      }
      {
        description = "Jogos Steam → painel 6";
        match.window-class = {
          value = "steam_app";
          type = "substring";
          match-whole = false;
        };
        apply.desktops = {
          value = "Desktop_6";
          apply = "initially";
        };
        # fsplevel=0 (None) lets the game steal focus so KWin follows to Desktop_6 and it keeps fullscreen
        apply.fsplevel = {
          value = 0;
          apply = "force";
        };
      }
    ];

    # Startup: launch terminal+browser (rules place them); Steam trays via gaming.nix. runAlways = every login
    startup.startupScript."session-layout" = {
      runAlways = true;
      text = ''
        # Wait for KWin (6 desktops) before launching, else apps land on desktop 1.
        # Sem plasmashell, gatear no VirtualDesktopManager do KWin (não no plasmashell,
        # que nunca sobe → estouraria o loop de 60s).
        i=0
        while [ "$i" -lt 120 ]; do
          if [ "$(qdbus org.kde.KWin /VirtualDesktopManager count 2>/dev/null)" = "6" ]; then
            break
          fi
          i=$((i + 1)); sleep 0.5
        done

        foot >/dev/null 2>&1 &
        brave >/dev/null 2>&1 &

        # Each new window pulls the current desktop; wait for brave then force focus to desktop 2
        i=0
        while [ "$i" -lt 120 ]; do
          [ "$(qdbus org.kde.KWin /VirtualDesktopManager current 2>/dev/null)" = "Desktop_2" ] && break
          i=$((i + 1)); sleep 0.5
        done
        sleep 1
        qdbus org.kde.KWin /KWin org.kde.KWin.setCurrentDesktop 2
      '';
    };

    shortcuts = {
      "services/vicinae.desktop"."toggle" = "Meta+Return";

      # Disable lone Super for the launcher (keep only Alt+F1)
      plasmashell."activate application launcher" = "Alt+F1";

      # App shortcuts — Super+Ctrl+Letter
      "foot.desktop"."_launch" = "Meta+Ctrl+T";
      "brave-browser.desktop"."_launch" = "Meta+Ctrl+B";
      "whatsapp-web.desktop"."_launch" = "Meta+Ctrl+G";

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
        # Krohnkite — free Meta+Return for vicinae
        "KrohnkiteSetMaster" = "none";
        # Krohnkite — layouts
        "KrohnkiteToggleFloat" = "Meta+F";
        "KrohnkiteFloatAll" = "Meta+Shift+F";
        "KrohnkiteMonocleLayout" = "Meta+M";
      };
    };
  };

  # kwalletmanager can't be removed via excludePackages — hide it from the menu instead
  xdg.dataFile = {
    "applications/whatsapp-web.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=WhatsApp Web
      Exec=brave --app=https://web.whatsapp.com
      Icon=brave-browser
      Categories=Network;InstantMessaging;
    '';
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
}
