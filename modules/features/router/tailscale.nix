{ ... }:
{
  # Router-scoped Tailscale subnet router for bellway.
  # The desktop Tailscale client in modules/features/tailscale.nix stays untouched.
  flake.nixosModules.tailscalerouter =
    { ... }:
    {
      services.tailscale = {
        enable = true;
        useRoutingFeatures = "server";
        authKeyFile = "/etc/tailscale/bellway-authkey";
        authKeyParameters = {
          preauthorized = true;
        };
        extraUpFlags = [
          "--advertise-routes=10.10.0.0/24"
          "--accept-dns=false"
          "--advertise-tags=tag:subnet-router"
          "--ssh"
        ];
        extraSetFlags = [
          "--advertise-routes=10.10.0.0/24"
          "--accept-dns=false"
          "--advertise-tags=tag:subnet-router"
          "--ssh"
        ];
      };
    };
}
