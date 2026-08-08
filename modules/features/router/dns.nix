{ ... }:
{
  # DNS + network-wide adblock — Blocky, fully declarative, no mutable runtime state.
  # Sole DNS daemon on the router. kea points every DHCP client here (gateway.nix).
  flake.nixosModules.dns =
    { ... }:
    {
      services.blocky = {
        enable = true;
        settings = {
          # Covers LAN + the dynamic tailscale0 IP + loopback; nftables drops WAN :53.
          ports.dns = "0.0.0.0:53";

          upstreams = {
            strategy = "parallel_best";
            groups.default = [
              "https://cloudflare-dns.com/dns-query"
              "https://dns.quad9.net/dns-query"
              "https://dns.mullvad.net/dns-query"
            ];
          };

          blocking = {
            denylists.default = [ "https://big.oisd.nl" ];
            allowlists.default = [ ];
            clientGroupsBlock.default = [ "default" ];
          };

          customDNS.mapping = {
            "bellway.lan" = "10.10.0.1";
          };

          queryLog.type = "none";
          prometheus.enable = true;
        };
      };
    };
}
