{ ... }:
{
  flake.nixosModules.android =
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
      environment.systemPackages = [
        pkgs.android-tools
        androidPackages.androidsdk
      ];

      services.udev.packages = [ pkgs.android-udev ];
    };
}
