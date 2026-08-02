{ ... }:
{
  flake.nixosModules.tailscale =
    {
      user ? "root",
      ...
    }:
    {
      services.tailscale = {
        enable = true;
        openFirewall = true;
        extraSetFlags = [ "--operator=${user}" ];
      };
    };
}
