{ ... }:
{
  flake.nixosModules.print =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        freecad
        orca-slicer
      ];
    };
}
