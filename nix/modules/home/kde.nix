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

    # Máquina de streaming: nunca apagar/escurecer a tela nem suspender. Sem
    # isso o KDE apaga o display (inclusive o dummy/virtual) por inatividade e
    # o stream vira tela preta. "never" já cobre bloqueado e desbloqueado.
    powerdevil.AC = {
      autoSuspend.action = "nothing";
      dimDisplay.enable = false;
      turnOffDisplay.idleTimeout = "never";
    };

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
      # Jogos Steam (Proton) têm resourceClass steam_app_<id>. O [substring]
      # faz o krohnkite ignorá-los 100% — sem isso ele tenta "tilar" a janela
      # fullscreen e ela some ao trocar de desktop (só reabria pelo ícone da
      # dock). Lista = defaults do krohnkite 0.9.9.2 + [steam_app].
      "kwinrc"."Script-krohnkite"."ignoreClass".value =
        "krunner,yakuake,spectacle,kded5,xwaylandvideobridge,plasmashell,ksplashqml,org.kde.plasmashell,org.kde.polkit-kde-authentication-agent-1,org.kde.kruler,kruler,kwin_wayland,ksmserver-logout-greeter,[steam_app]";
    };

    # Posicionamento por app (initially = posiciona ao abrir, mas deixa mover
    # depois). Desktop_N é o Id estável do N-ésimo virtual desktop (ver
    # [Desktops] no kwinrc — plasma-manager fixa via virtualDesktops). Os apps
    # de startup são lançados em startup.startupScript abaixo (Steam vem do
    # gaming.nix). window-class confirmado na sessão: foot / brave-browser /
    # steam (o cliente; "steam" exato não colide com os "steam_app_<id>" dos
    # jogos).
    window-rules = [
      # match-whole = false (wmclasscomplete=false) casa só a resourceClass; com
      # true o KWin compara "resourceName resourceClass" inteiro e nunca bate
      # (ex.: brave é "brave brave-browser", steam é "steamwebhelper steam").
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
        # Jogo fullscreen minimiza sozinho ao perder o foco (troca de painel).
        # force minimize=false faz o KWin recusar o pedido de minimizar, então
        # a janela continua no painel 6 e recupera o foco ao voltar.
        apply.minimize = {
          value = false;
          apply = "force";
        };
      }
    ];

    # Layout de startup: lança terminal e navegador; as window-rules acima
    # posicionam cada um (foot→1, brave→2). O Steam sobe silencioso na bandeja
    # pelo gaming.nix. runAlways = roda a cada login (não só quando a config muda).
    startup.startupScript."session-layout" = {
      runAlways = true;
      text = ''
        # Espera o Plasma ficar realmente pronto antes de lançar: painel
        # (plasmashell) no DBus e o kwin já com os 6 virtual desktops. O
        # autostart dispara no ksmserver, cedo demais — sem esta espera os apps
        # abrem antes das window-rules/desktops existirem e caem todos no 1.
        i=0
        while [ "$i" -lt 120 ]; do
          if qdbus org.kde.plasmashell /PlasmaShell >/dev/null 2>&1 \
             && [ "$(qdbus org.kde.KWin /VirtualDesktopManager count 2>/dev/null)" = "6" ]; then
            break
          fi
          i=$((i + 1)); sleep 0.5
        done

        foot >/dev/null 2>&1 &
        brave >/dev/null 2>&1 &

        # Cada janela que abre puxa o desktop atual pra ela; o brave é quem
        # chaveia pro 2. Espera ele abrir e então garante o foco no desktop 2.
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

      # Desativa Super sozinho no app launcher (só mantém Alt+F1)
      plasmashell."activate application launcher" = "Alt+F1";

      # Atalhos de apps — Super+Ctrl+Letra
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
