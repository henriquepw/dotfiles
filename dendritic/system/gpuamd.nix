{ ... }:
{
  flake.nixosModules.gpuamd =
    { pkgs, ... }:
    {
      boot.kernelPackages = pkgs.linuxPackages_zen;
      boot.initrd.kernelModules = [ "amdgpu" ];

      services.xserver.videoDrivers = [ "amdgpu" ];

      hardware.amdgpu.opencl.enable = true;

      environment.systemPackages = with pkgs; [
        libva-utils
      ];

      # VAAPI radeonsi — usado pelo sunshine e players de vídeo
      environment.sessionVariables = {
        LIBVA_DRIVER_NAME = "radeonsi";
        LIBVA_DRIVERS_PATH = "/run/opengl-driver/lib/dri";
      };
    };
}
