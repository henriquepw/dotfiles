{ ... }:
{
  # Remote access (§6) — NetBird Cloud client, outbound-only (WAN stays fully closed).
  # The router is a routing peer advertising 10.10.0.0/24, so remote devices reach the whole LAN.
  # Route approval + nameserver group are configured in the NetBird dashboard post-deploy.
  flake.nixosModules.netbird =
    { ... }:
    {
      services.netbird.clients.bellway = {
        port = 51820; # WireGuard port on wt0, not exposed on WAN
        interface = "wt0";
        # Outbound-only agent — no inbound WireGuard hole; our nftables is authoritative.
        openFirewall = false;
        hardened = false;

        # Headless enrollment via setup key. Plaintext file at an absolute system path,
        # out-of-band from the flake (never a ./store secret). Consumed once at first enrollment.
        # Drop it at /etc/netbird/bellway-setup-key (root, 0600) before first activation (§6, §9).
        login = {
          enable = true;
          setupKeyFile = "/etc/netbird/bellway-setup-key";
          systemdDependencies = [ "network-online.target" ];
        };
      };
    };
}
