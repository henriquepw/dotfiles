{ ... }:
{
  flake.nixosModules.develop =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        nodejs
        bun
        go
        zig
        rustup
      ];
    };
}
