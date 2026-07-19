{
  lib,
  config,
  dotfiles,
  ...
}:
let
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  home.file.".XCompose".source = link "${dotfiles}/kde/XCompose";

  # Noctalia is the shell; the Plasma session still auto-starts plasmashell as a
  # systemd user service, so mask it (symlink to /dev/null) to keep it from running.
  xdg.configFile."systemd/user/plasma-plasmashell.service".source = link "/dev/null";

  # KWin script: no native "center at 50%" action, so it self-registers a shortcut (enabled via centerhalfEnabled below)
  home.file.".local/share/kwin/scripts/centerhalf/metadata.json".text = builtins.toJSON {
    KPlugin = {
      Id = "centerhalf";
      Name = "Center Half";
      Description = "Centraliza a janela em foco a ~50% do monitor";
      Version = "1.0";
      EnabledByDefault = true;
    };
    "X-Plasma-API" = "javascript";
    "X-Plasma-MainScript" = "code/main.js";
    KPackageStructure = "KWin/Script";
  };

  home.file.".local/share/kwin/scripts/centerhalf/contents/code/main.js".text = ''
    // Per-axis linear fraction (0.7 x 0.7 ≈ 49% area = "half the monitor")
    var FRAC = 0.7;
    registerShortcut("CenterHalf", "Centralizar janela a 50%", "Meta+Ctrl+F", function () {
      var w = workspace.activeWindow;
      if (!w || !w.normalWindow) return;
      var area = workspace.clientArea(KWin.MaximizeArea, w);
      var width = Math.round(area.width * FRAC);
      var height = Math.round(area.height * FRAC);
      w.frameGeometry = {
        x: area.x + Math.round((area.width - width) / 2),
        y: area.y + Math.round((area.height - height) / 2),
        width: width,
        height: height,
      };
    });
  '';

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

    workspace = {
      iconTheme = "Papirus-Dark";
      wallpaper = "${dotfiles}/wallpaper.png";
    };

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
      "kwalletrc"."Wallet"."Enabled".value = false;
      "kwinrc"."Plugins"."slideEnabled".value = false;
      "kwinrc"."Plugins"."centerhalfEnabled".value = true;

      # Keep Breeze as base decoration; the global noborder window-rule below strips title + frame
      "kwinrc"."org.kde.kdecoration2"."library".value = "org.kde.breeze";
      "kwinrc"."org.kde.kdecoration2"."theme".value = "Breeze";
      "kwinrc"."org.kde.kdecoration2"."ButtonsOnLeft".value = "";
      "kwinrc"."org.kde.kdecoration2"."ButtonsOnRight".value = "";

      # No shadow (Breeze decoration + compositor effect)
      "kwinrc"."Plugins"."kwin4_effect_shadowEnabled".value = false;
      "breezerc"."Common"."ShadowSize".value = "ShadowNone";
      "breezerc"."Common"."ShadowStrength".value = 0;
      "breezerc"."Common"."OutlineIntensity".value = "OutlineOff";
    };

    # Per-app placement (initially = place on open, still movable); Desktop_N is the stable virtual-desktop id
    window-rules = [
      # Strip title bar + frame from all windows (regex .* matches any class)
      {
        description = "Sem barra de título (global)";
        match.window-class = {
          value = ".*";
          type = "regex";
          match-whole = false;
        };
        apply.noborder = {
          value = true;
          apply = "force";
        };
      }
      # match-whole=false matches only resourceClass (true compares "name class" and never hits)
      {
        description = "Terminal → panel 1";
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
        description = "Browser → panel 2";
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
        description = "Steam → panel 5";
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
        description = "Steam Games → panel 6";
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
        # Wait for KWin (6 desktops) before launching, else apps land on desktop 1 (no plasmashell, so gate on KWin)
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

    # Noctalia registers its own NoctaliaToggleLauncher shortcut (Meta+Return); don't duplicate it with hotkeys.commands
    shortcuts = {
      plasmashell."activate application launcher" = "Alt+F1";

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
        "Window Quick Tile Left" = "Meta+Ctrl+H";
        "Window Quick Tile Bottom" = "Meta+Ctrl+J";
        "Window Quick Tile Top" = "Meta+Ctrl+K";
        "Window Quick Tile Right" = "Meta+Ctrl+L";
        "Window Maximize" = "Meta+Ctrl+M";
        # Meta+Ctrl+F is registered by the centerhalf KWin script.
      };
    };
  };

  xdg.dataFile = {
    "applications/whatsapp-web.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=WhatsApp Web
      Exec=brave --app=https://web.whatsapp.com
      Icon=whatsapp
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
