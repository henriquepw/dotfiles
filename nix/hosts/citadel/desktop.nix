{ pkgs, lib, ... }:
{
  services.displayManager.ly = {
    enable = true;
    settings.xsessions = ""; # hide all X11 sessions
  };

  services.desktopManager.plasma6.enable = true;

  # kwrite vem dentro do pacote kate; kwalletmanager é "required" pelo módulo
  # (KCMs) e não sai por aqui — o .desktop dele é escondido no kde.nix
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    kate
    okular
    gwenview
    elisa
    khelpcenter
    konsole
  ];

  # us-intl: dead keys ('+c, ~+a, etc.) — o KDE Wayland lê o kxkbrc (kde.nix),
  # isto cobre console/X e o fallback do sistema
  services.xserver.xkb = {
    layout = "us";
    variant = "intl";
  };

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

  programs.kdeconnect.enable = true;

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
    # VAAPI para AMD — necessário para Sunshine usar encoder radeonsi em vez de Vulkan (GFX1201/RDNA4 ainda imaturo no RADV)
    LIBVA_DRIVER_NAME = "radeonsi";
    LIBVA_DRIVERS_PATH = "/run/opengl-driver/lib/dri";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  };
}
