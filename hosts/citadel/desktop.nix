{ pkgs, ... }:
{
  services.displayManager.ly.enable = true;

  services.desktopManager.plasma6.enable = true;

  programs.dconf.enable = true;

  security.polkit.enable = true;

  # Force Wayland session
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  };
}
