{ ... }:
{
  flake.nixosModules.network =
    { ... }:
    {
      networking.networkmanager.enable = true;
      hardware.enableRedistributableFirmware = true;

      boot.kernel.sysctl = {
        "net.core.default_qdisc" = "fq";
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.core.rmem_max" = 134217728;
        "net.core.wmem_max" = 134217728;
        "net.ipv4.tcp_rmem" = "4096 87380 134217728";
        "net.ipv4.tcp_wmem" = "4096 65536 134217728";
      };
    };
}
