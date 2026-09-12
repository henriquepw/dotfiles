{ ... }:
{
  flake.nixosModules.sable =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        sable
      ];
    };
}
