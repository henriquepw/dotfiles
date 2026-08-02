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

        claude-code
        opencode
      ];

      my.unfree = [ "claude-code" ];
    };
}
