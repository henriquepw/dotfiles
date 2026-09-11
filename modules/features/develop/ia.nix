{ ... }:
{
  flake.nixosModules.ia =
    { pkgs, ... }:
    let
      androidPackages = pkgs.androidenv.composeAndroidPackages {
        platformVersions = [ "35" ];
        buildToolsVersions = [ "35.0.0" ];
        includeEmulator = true;
        includeSystemImages = false;
        includeSources = false;
        includeNDK = false;
      };
    in
    {
      environment.systemPackages = with pkgs; [
        claude-code
        codex
        opencode
      ];

      my.unfree = [ "claude-code" ];
    };
}
