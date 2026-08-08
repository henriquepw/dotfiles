{ ... }:
{
  # Edge-router internals (§4): NIC pinning, WAN DHCP, LAN addressing, kea DHCP server,
  # nftables ruleset, IPv4 forwarding, and the USB-NIC link-watchdog.
  flake.nixosModules.gateway =
    { pkgs, ... }:
    let
      lanSubnet = "10.10.0.0/24";
      lanGateway = "10.10.0.1";
    in
    {
      # 4.1 — Stable interface names pinned by udev so the USB adapter never renames across
      # resets/reboots. MACs are placeholders: fill in with the real addresses on-device
      # (`ip link` after install), matching WAN = onboard 1GbE, LAN = USB 2.5GbE.
      systemd.network.links = {
        "10-wan0" = {
          matchConfig.MACAddress = "00:00:00:00:00:00"; # TODO on-device: onboard I217-LM MAC
          linkConfig.Name = "wan0";
        };
        "10-lan0" = {
          matchConfig.MACAddress = "00:00:00:00:00:01"; # TODO on-device: USB 2.5GbE adapter MAC
          linkConfig.Name = "lan0";
        };
      };

      # 4.2 / 4.4 — WAN pulls DHCP from the ONU; LAN carries the static gateway address.
      networking.useDHCP = false;
      networking.interfaces = {
        wan0.useDHCP = true;
        lan0.ipv4.addresses = [
          {
            address = lanGateway;
            prefixLength = 24;
          }
        ];
      };

      # Own the firewall via nftables directly, not the per-port firewall module (§3).
      networking.firewall.enable = false;

      # 4.7 — IPv4 forwarding (router). IPv6 mirrored later if the ISP provides RA/DHCPv6.
      boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

      # 4.3 — kea, DHCP-only. Static reservations .2–.99, dynamic pool .100–.240.
      # DNS option points every client at Blocky on 10.10.0.1 (network-wide adblock).
      services.kea.dhcp4 = {
        enable = true;
        settings = {
          interfaces-config.interfaces = [ "lan0" ];
          lease-database = {
            type = "memfile";
            persist = true;
            name = "/var/lib/kea/dhcp4.leases";
          };
          valid-lifetime = 4000;
          renew-timer = 1000;
          rebind-timer = 2000;
          subnet4 = [
            {
              id = 1;
              subnet = lanSubnet;
              pools = [ { pool = "10.10.0.100 - 10.10.0.240"; } ];
              option-data = [
                {
                  name = "routers";
                  data = lanGateway;
                }
                {
                  name = "domain-name-servers";
                  data = lanGateway;
                }
              ];
              # Static reservations mirror Blocky's .lan A-records (dns.nix). MACs TODO on-device.
              reservations = [
                # { hw-address = "..."; ip-address = "10.10.0.2"; hostname = "mesh"; }
                # { hw-address = "..."; ip-address = "10.10.0.3"; hostname = "switch"; }
              ];
            }
          ];
        };
      };

      # 4.5 — concrete nftables ruleset. Default-deny input AND forward, stateful.
      networking.nftables.enable = true;
      networking.nftables.ruleset = ''
        table inet filter {
          chain input {
            type filter hook input priority 0; policy drop;

            ct state established,related accept
            iif "lo" accept

            # WAN fully closed — no public SSH, no port-forwards, no inbound holes.
            iifname "wan0" drop

            # LAN: DHCP, DNS (Blocky), SSH, ICMP.
            iifname "lan0" udp dport 67 accept
            iifname "lan0" tcp dport 53 accept
            iifname "lan0" udp dport 53 accept
            iifname "lan0" tcp dport 22 accept
            iifname "lan0" ip protocol icmp accept

            # Tailscale peers: DNS (Blocky), SSH/Tailscale SSH, ICMP.
            iifname "tailscale0" tcp dport 53 accept
            iifname "tailscale0" udp dport 53 accept
            iifname "tailscale0" tcp dport 22 accept
            iifname "tailscale0" ip protocol icmp accept
          }

          chain forward {
            type filter hook forward priority 0; policy drop;

            ct state established,related accept
            iifname "lan0" oifname "wan0" accept   # LAN -> internet
            iifname "tailscale0" oifname "lan0" ip daddr 10.10.0.0/24 accept # tailnet peers -> LAN hosts
            # WAN -> LAN drops by default (only est/related above pass).
          }

          chain output {
            type filter hook output priority 0; policy accept;
          }
        }

        table inet nat {
          chain postrouting {
            type nat hook postrouting priority srcnat; policy accept;
            oifname "wan0" masquerade
          }
        }
      '';

      # 4.1 — link-watchdog: recover the USB LAN link after a USB reset.
      systemd.services.lan0-watchdog = {
        description = "Recover LAN (USB 2.5GbE) link after USB reset";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        path = [ pkgs.iproute2 ];
        serviceConfig = {
          Restart = "always";
          RestartSec = "5s";
        };
        script = ''
          set -eu
          while true; do
            if ! ip link show lan0 up >/dev/null 2>&1; then
              ip link set lan0 up || true
            fi
            sleep 10
          done
        '';
      };
    };
}
