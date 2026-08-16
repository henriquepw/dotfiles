{ ... }:
{
  flake.nixosModules.develop =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        # langs
        nodejs
        bun
        go
        zig
        rustup

        # devtools
        watchexec

        # ai
        claude-code
        codex
        opencode
      ];

      my.unfree = [ "claude-code" ];
    };
}
