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
        codex
        opencode
      ];

      my.unfree = [ "claude-code" ];
    };
}
