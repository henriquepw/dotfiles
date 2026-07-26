{ pkgs, lib, ... }:
{
  services.displayManager.ly = {
    enable = true;
    settings.xsessions = "";
  };

  services.desktopManager.plasma6.enable = true;

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    kate
    okular
    gwenview
    elisa
    khelpcenter
    konsole
  ];

  services.xserver.xkb = {
    layout = "us";
    variant = "intl";
  };

  services.displayManager.sddm.enable = false;

  # KWallet off: no PAM auto-unlock (mkForce since plasma6 enables it by default; subsystem itself disabled via kwalletrc in kde.nix)
  security.pam.services = {
    login.kwallet.enable = lib.mkForce false;
    kde.kwallet.enable = lib.mkForce false;
  };

  programs.kdeconnect.enable = true;

  programs.dconf.enable = true;

  security.polkit.enable = true;

  environment.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    LIBVA_DRIVER_NAME = "radeonsi";
    LIBVA_DRIVERS_PATH = "/run/opengl-driver/lib/dri";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  };
}
