{ ... }:
# DNS + network-wide adblock (§5) — Blocky, fully declarative, no mutable runtime state.
# Sole DNS daemon on bellway. kea points every DHCP client here (router.nix).
{
  services.blocky = {
    enable = true;
    settings = {
      # Covers LAN + the dynamic wt0 (NetBird) IP + loopback; nftables drops WAN :53.
      ports.dns = "0.0.0.0:53";

      # Encrypted DoH upstreams; parallel_best races 2 random of the 3 per query.
      # All no-filter endpoints — Blocky owns the blocking.
      upstreams = {
        strategy = "parallel_best";
        groups.default = [
          "https://cloudflare-dns.com/dns-query"
          "https://dns.quad9.net/dns-query"
          "https://dns.mullvad.net/dns-query"
        ];
      };

      # Adblock — OISD Big only (conservative; Hagezi over-blocks here today).
      blocking = {
        denylists.default = [ "https://big.oisd.nl" ];
        # Empty personal allowlist to grow over time.
        allowlists.default = [ ];
        clientGroupsBlock.default = [ "default" ];
      };

      # Local .lan names — static A-records mirroring kea reservations (router.nix §4.4).
      customDNS.mapping = {
        "bellway.lan" = "10.10.0.1";
        # "mesh.lan"    = "10.10.0.2";
        # "switch.lan"  = "10.10.0.3";
        # "citadel.lan" = "10.10.0.x";
      };

      # Observability — no query log (no per-family browsing history); errors still hit the
      # normal log. Prometheus on for a future Grafana dashboard.
      queryLog.type = "none";
      prometheus.enable = true;
    };
  };
}
