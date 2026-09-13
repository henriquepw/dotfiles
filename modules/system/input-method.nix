{ ... }:
{
  # Wayland-native IME so Brave/Chromium (ozone-wayland) can receive compose
  # sequences (e.g. dead_acute+c -> ç from ~/.XCompose). Chromium on Wayland
  # doesn't load any GTK immodule, so GTK_IM_MODULE/QT_IM_MODULE (used for
  # X11/XWayland apps) have no effect there; fcitx5's Wayland frontend talks
  # input-method-v2/text-input-v3 directly to the compositor instead.
  flake.nixosModules.inputMethod =
    { pkgs, ... }:
    {
      i18n.inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5.waylandFrontend = true;
      };

      environment.systemPackages = [ pkgs.qt6Packages.fcitx5-configtool ];
    };
}
