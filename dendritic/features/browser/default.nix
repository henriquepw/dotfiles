{ ... }:
{
  flake.nixosModules.browser =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.brave
      ];

      # Wayland para apps Chromium/Electron (brave) e Firefox
      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        MOZ_ENABLE_WAYLAND = "1";
      };

      home-manager.sharedModules = [
        (
          {
            config,
            lib,
            pkgs,
            repoRoot,
            link,
            ...
          }:
          {
            # Force x11 so Brave respects ~/.XCompose (cedilla ç); native Wayland Chromium ignores it.
            home.packages = [
              (pkgs.brave.override { commandLineArgs = [ "--ozone-platform=x11" ]; })
            ];

            xdg.configFile."brave-origin-beta-flags.conf".source =
              link "${repoRoot}/dendritic/features/browser/config/brave-origin-beta-flags.conf";

            # Default browser — mimeapps covers xdg-open; kdeglobals covers what KDE resolves itself.
            xdg.mimeApps = {
              enable = true;
              defaultApplications = {
                "text/html" = "brave-browser.desktop";
                "x-scheme-handler/http" = "brave-browser.desktop";
                "x-scheme-handler/https" = "brave-browser.desktop";
                "x-scheme-handler/about" = "brave-browser.desktop";
                "x-scheme-handler/unknown" = "brave-browser.desktop";
              };
            };
            # force = true: KDE/Brave rewrite mimeapps.list at runtime, so overwrite it without backup (fully declarative here).
            xdg.configFile."mimeapps.list".force = true;
            programs.plasma.configFile."kdeglobals"."General"."BrowserApplication".value =
              "brave-browser.desktop";

            home.sessionVariables = {
              BROWSER = "brave";
              GTK_IM_MODULE = "cedilla";
              QT_IM_MODULE = "cedilla";
            };

            home.activation.braveQtTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              prefs="${config.xdg.configHome}/BraveSoftware/Brave-Browser/Default/Preferences"
              if [ -f "$prefs" ]; then
                tmp="$(mktemp)"
                if ${pkgs.jq}/bin/jq \
                  '.extensions.theme.system_theme = 2
                   | .browser.theme.color_scheme = 2
                   | .browser.theme.color_scheme2 = 2' \
                  "$prefs" > "$tmp" 2>/dev/null && ! cmp -s "$tmp" "$prefs"; then
                  run cp "$tmp" "$prefs"
                fi
                rm -f "$tmp"
              fi
            '';
          }
        )
      ];
    };
}
