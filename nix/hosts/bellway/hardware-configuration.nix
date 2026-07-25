{ lib, modulesPath, ... }:
# ⚠️ PLACEHOLDER — regenerate ON-DEVICE at install with `nixos-generate-config`, then commit.
# This stub only exists so the flake evaluates before bellway is provisioned (spec §2, §10.2).
# Do NOT deploy as-is: the device labels/UUIDs and kernel modules below are guesses.
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "usb_storage"
    "sd_mod"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault false;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
}
