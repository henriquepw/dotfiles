{ ... }:
{
  flake.nixosModules.network =
    { ... }:
    {
      networking.networkmanager.enable = true;
      hardware.enableRedistributableFirmware = true;
    };
}
