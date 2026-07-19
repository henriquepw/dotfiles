{ pkgs, ... }:
{
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.initrd.kernelModules = [ "amdgpu" ];

  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    # VAAPI radeonsi (radeonsi_drv_video.so) já vem no mesa 26.x — nada a adicionar aqui
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
        renice = 10; # prioriza o processo do jogo
      };
      # Sobe a GPU pra performance máxima enquanto o jogo roda (volta ao auto no fim)
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

  # Sunshine — binário com setcap (captura KMS + uinput no Wayland)
  services.sunshine = {
    enable = true;
    capSysAdmin = true;
    autoStart = true;
    openFirewall = true;
  };

  # EDID forçado no DP-3, onde vive o dummy plug "DP1080P60".
  # O EDID real do plug só anuncia 1080p60; o plug em si só termina o link
  # elétrico, então sobrescrevemos o EDID para o KWin renderizar 4K60 e o
  # Sunshine capturar/streamar nessa resolução (modelines CVT-RB p/ menos banda).
  hardware.display = {
    edid.modelines = {
      "DP3_4K60" = "533.00 3840 3888 3920 4000 2160 2163 2168 2222 +hsync -vsync";
    };
    outputs."DP-3" = {
      edid = "DP3_4K60.bin";
      mode = "e"; # força o output habilitado, pulando checagens do amdgpu
    };
  };

  # vainfo — debug do encoder VAAPI (radeonsi) usado pelo Sunshine
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
