{ ... }:
{
  flake.nixosModules.browser =
    { pkgs, ... }:
    {
      # Wayland para apps Chromium/Electron e Firefox
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
            inputs,
            featurePath,
            link,
            ...
          }:
          {
            # Force x11 so Brave respects ~/.XCompose (cedilla ç); native Wayland Chromium ignores it.
            home.packages = [
              # brave-origin only exists in nixpkgs unstable; pulled from the dedicated input.
              (inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.brave-origin.override {
                commandLineArgs = [ "--ozone-platform=x11" ];
              })
            ];

            xdg.configFile."brave-origin-beta-flags.conf".source =
              link "${featurePath}/browser/config/brave-origin-beta-flags.conf";

            # Default browser — mimeapps covers xdg-open; kdeglobals covers what KDE resolves itself.
            xdg.mimeApps = {
              enable = true;
              defaultApplications = {
                "text/html" = "brave-origin.desktop";
                "x-scheme-handler/http" = "brave-origin.desktop";
                "x-scheme-handler/https" = "brave-origin.desktop";
                "x-scheme-handler/about" = "brave-origin.desktop";
                "x-scheme-handler/unknown" = "brave-origin.desktop";
              };
            };
            # force = true: KDE/Brave rewrite mimeapps.list at runtime, so overwrite it without backup (fully declarative here).
            xdg.configFile."mimeapps.list".force = true;
            programs.plasma.configFile."kdeglobals"."General"."BrowserApplication".value =
              "brave-origin.desktop";

            home.sessionVariables = {
              BROWSER = "brave-origin";
              GTK_IM_MODULE = "cedilla";
              QT_IM_MODULE = "cedilla";
            };

            home.activation.braveQtTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              prefs="${config.xdg.configHome}/BraveSoftware/Brave-Origin/Default/Preferences"
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
