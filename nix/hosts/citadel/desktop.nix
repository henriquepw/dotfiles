{ pkgs, lib, ... }:
{
  services.displayManager.ly = {
    enable = true;
    settings.xsessions = ""; # hide all X11 sessions
  };

  services.desktopManager.plasma6.enable = true;

  # Login é o ly; SDDM fica 100% fora (não é ele que bloqueia a tela — isso é o
  # kscreenlocker + PAM, que seguem funcionando)
  services.displayManager.sddm.enable = false;

  # KWallet desligado: sem auto-unlock no PAM (mkForce porque o plasma6 liga por
  # padrão). O subsistema em si é desativado via kwalletrc no kde.nix.
  # A lib kwallet do framework permanece — o plasma-workspace linka contra ela.
  security.pam.services = {
    login.kwallet.enable = lib.mkForce false;
    kde.kwallet.enable = lib.mkForce false;
  };

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
