{ ... }:
# Host-agnostic system base, shared by every host (citadel desktop, bellway router).
# Kept distinct from nix/modules/ which is home-manager desktop-only.
# Desktop/gaming/audio and citadel's noctalia cachix stay inline in the host, not here.
{
  programs.zsh.enable = true;

  time.timeZone = "America/Sao_Paulo";
  services.timesyncd.enable = true;

  # Locale — English UI, pt-BR formats (date, currency, paper...)
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_CTYPE = "pt_BR.UTF-8";
      LC_TIME = "pt_BR.UTF-8";
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
      LC_PAPER = "pt_BR.UTF-8";
      LC_NAME = "pt_BR.UTF-8";
      LC_ADDRESS = "pt_BR.UTF-8";
      LC_TELEPHONE = "pt_BR.UTF-8";
      LC_MEASUREMENT = "pt_BR.UTF-8";
    };
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };
}
