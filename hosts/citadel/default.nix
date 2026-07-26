{
  inputs,
  pkgs,
  system,
  ...
}:
{
  imports = [
    ../../system/common.nix
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
      ];
    }
  ];

  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.consoleMode = "max"; # max EFI resolution so ly fills the whole monitor
    efi.canTouchEfiVariables = true;
  };

  boot.kernelParams = [
    "quiet"
    "loglevel=3"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    "video=DP-1:2560x1440@165" # force KMS to native resolution on the TTY/ly
  ];

  networking = {
    hostName = "citadel";
    networkmanager.enable = true;
  };

  # Tailscale — operator lets the user run the CLI without sudo
  services.tailscale = {
    enable = true;
    openFirewall = true;
    extraSetFlags = [ "--operator=henrique" ];
  };

  hardware.enableRedistributableFirmware = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Meta+c/v/x/a/z → universal Ctrl/Shift+Insert copy/paste; terminals bind explicitly (terminal.nix)
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

  # noctalia cachix — desktop-only, stays inline (not lifted into common.nix)
  nix.settings = {
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  system.stateVersion = "24.11";
}
