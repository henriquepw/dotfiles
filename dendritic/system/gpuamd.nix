{ ... }:
{
  flake.nixosModules.gpuamd =
    { pkgs, ... }:
    {
      boot.kernelPackages = pkgs.linuxPackages_zen;
      boot.initrd.kernelModules = [ "amdgpu" ];

      services.xserver.videoDrivers = [ "amdgpu" ];

      hardware.amdgpu.opencl.enable = true;

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [ rocmPackages.clr.icd ];
      };

      environment.systemPackages = with pkgs; [
        libva-utils
      ];

      # VAAPI radeonsi — used by sunshine and video playes
      environment.sessionVariables = {
        LIBVA_DRIVER_NAME = "radeonsi";
        LIBVA_DRIVERS_PATH = "/run/opengl-driver/lib/dri";
      };
    };
}
