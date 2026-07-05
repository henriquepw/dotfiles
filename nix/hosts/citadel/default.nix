{
  inputs,
  pkgs,
  system,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./gaming.nix
    ./desktop.nix
    ./theme.nix
    inputs.stylix.nixosModules.stylix
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "hm-bak";
      home-manager.users.henrique = import ./home.nix;
      home-manager.extraSpecialArgs = { inherit inputs system; };
      home-manager.sharedModules = [
        inputs.plasma-manager.homeModules.plasma-manager
        inputs.vicinae.homeManagerModules.default
      ];
    }
  ];

  # Boot
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Network
  networking = {
    hostName = "citadel";
    networkmanager.enable = true;
  };

  # Tailscale
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  # Time
  time.timeZone = "America/Sao_Paulo";
  services.timesyncd.enable = true;

  # Locale
  # 'c → ç vem do ~/.XCompose (home-manager), lido nativamente pelo xkbcommon
  i18n = {
    defaultLocale = "pt_BR.UTF-8";
    extraLocaleSettings.LC_CTYPE = "pt_BR.UTF-8";
  };

  # Firmware
  hardware.enableRedistributableFirmware = true;

  # Audio (pipewire)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Keyboard remapping
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.meta = {
        c = "C-S-c";
        v = "C-v";
        x = "C-x";
        a = "C-a";
        z = "C-z";
      };
    };
  };

  # Fonts — defaults do fontconfig vêm do stylix (theme.nix)
  # Noto completo como fallback de cobertura (CJK, símbolos, etc.)
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
  ];

  # Power
  services.power-profiles-daemon.enable = true;

  users.users.henrique = {
    initialPassword = "123";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "input"
    ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

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
      options = "--delete-older-than 30d";
    };
  };

  system.stateVersion = "24.11";
}
