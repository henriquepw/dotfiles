{ ... }:
{
  flake.nixosModules.office =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.onlyoffice-desktopeditors
      ];

      my.unfree = [ "onlyoffice-desktopeditors" ];
    };
}
