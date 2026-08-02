{ ... }:
{
  flake.nixosModules.tailscale =
    { ... }:
    {
      services.tailscale = {
        enable = true;
        openFirewall = true;
        extraSetFlags = [ "--operator=henrique" ];
      };
    };
}
