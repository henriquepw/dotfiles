{ pkgs, ... }:
{
  services.displayManager.ly = {
    enable = true;
    settings.xsessions = "";  # hide all X11 sessions
  };

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = false;

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
