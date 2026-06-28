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
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.henrique = import ./home.nix;
      home-manager.extraSpecialArgs = { inherit inputs system; };
      home-manager.sharedModules = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];
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

  # Time
  time.timeZone = "America/Sao_Paulo";
  services.timesyncd.enable = true;

  # Locale
  i18n = {
    defaultLocale = "pt_BR.UTF-8";
    inputMethod = {
      enabled = "ibus";
      ibus.engines = with pkgs.ibus-engines; [ uniemoji ];
    };
    extraLocaleSettings.LC_CTYPE = "pt_BR.UTF-8";
  };

  environment.variables = {
    GTK_IM_MODULE = "ibus";
    QT_IM_MODULE = "ibus";
    XMODIFIERS = "@im=ibus";
  };

  # Firmware
  hardware.enableRedistributableFirmware = true;

  # Audio (pipewire)
  hardware.pulseaudio.enable = false;
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

  # Fonts
  fonts = {
    packages = with pkgs; [
      noto-fonts-emoji
    ];
    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font Mono" ];
      sansSerif = [ "JetBrainsMono Nerd Font Mono" ];
      serif = [ "JetBrainsMono Nerd Font Mono" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  # Power
  services.power-profiles-daemon.enable = true;

  users.users.henrique = {
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
