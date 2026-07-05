{ pkgs, ... }:
{
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.initrd.kernelModules = [ "amdgpu" ];

  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
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

  programs.gamemode.enable = true;

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

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "steam"
      "steam-original"
      "steam-unwrapped"
      "proton-ge-bin"
      "onlyoffice-desktopeditors"
      "claude-code"
    ];

  services.flatpak.enable = true;
}
