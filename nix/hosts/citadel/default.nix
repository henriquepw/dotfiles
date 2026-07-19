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
    systemd-boot.consoleMode = "max"; # usa resolução máxima EFI — ly ocupa o monitor inteiro
    efi.canTouchEfiVariables = true;
  };

  boot.kernelParams = [
    "quiet"
    "loglevel=3"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    "video=DP-1:2560x1440@165" # força KMS a usar resolução nativa no TTY/ly
  ];

  # Network
  networking = {
    hostName = "citadel";
    networkmanager.enable = true;
  };

  # Tailscale — operator libera o CLI pro usuário sem sudo
  services.tailscale = {
    enable = true;
    openFirewall = true;
    extraSetFlags = [ "--operator=henrique" ];
  };

  # Time
  time.timeZone = "America/Sao_Paulo";
  services.timesyncd.enable = true;

  # Locale — UI em inglês, formatos (data, moeda, papel...) em pt-BR
  # 'c → ç vem do ~/.XCompose (home-manager), lido nativamente pelo xkbcommon
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

  # Keyboard remapping — Ctrl+Insert/Shift+Insert são copy/paste universais:
  # GTK, Qt, browsers e Electron honram nativamente; foot e ghostty têm
  # bindings explícitos pra eles (terminal.nix)
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.meta = {
        c = "C-insert";
        v = "S-insert";
        x = "C-x";
        a = "C-a";
        z = "C-z";
      };
    };
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
  ];

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
      extra-substituters = [ "https://noctalia.cachix.org" ];
      extra-trusted-public-keys = [
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  system.stateVersion = "24.11";
}
