{ ... }:
{
  flake.nixosModules.sable =
    { unstable, ... }:
    {
      environment.systemPackages = [
        unstable.sable
      ];
    };
}
