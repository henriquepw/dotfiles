{ self, ... }:
{
  flake.nixosModules.router.imports = with self.nixosModules; [
    dns
    gateway
    netbird
  ];
}
