{ pkgs, ... }:
{
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.initrd.kernelModules = [ "amdgpu" ];

  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    # VAAPI radeonsi (radeonsi_drv_video.so) already ships in mesa 26.x — nothing to add here
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];
  };

  hardware.amdgpu.opencl.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
    gamescopeSession.enable = false;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };

  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10; # prioritize the game process
      };
      # Push GPU to max performance while the game runs (reverts to auto afterward)
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        amd_performance_level = "high";
      };
    };
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  # Sunshine — setcap binary (KMS capture + uinput on Wayland)
  services.sunshine = {
    enable = true;
    capSysAdmin = true;
    autoStart = true;
    openFirewall = true;
  };

  # EDID override on DP-3 (dummy plug advertises only 1080p60) so KWin renders 4K60 and Sunshine streams it (CVT-RB modeline for less bandwidth)
  hardware.display = {
    edid.modelines = {
      "DP3_4K60" = "533.00 3840 3888 3920 4000 2160 2163 2168 2222 +hsync -vsync";
    };
    outputs."DP-3" = {
      edid = "DP3_4K60.bin";
      mode = "e"; # force the output enabled, skipping amdgpu checks
    };
  };

  # vainfo — debug the VAAPI (radeonsi) encoder used by Sunshine
  environment.systemPackages = [ pkgs.libva-utils ];

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "steam"
      "steam-original"
      "steam-unwrapped"
      "proton-ge-bin"
      "onlyoffice-desktopeditors"
      "claude-code"
      "discord"
    ];

  services.flatpak.enable = true;
}
