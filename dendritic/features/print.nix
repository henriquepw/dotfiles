{ ... }:
{
  flake.nixosModules.print =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        orca-slicer
      ];
    };
}
