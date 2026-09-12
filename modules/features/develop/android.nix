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

      nixpkgs.config.android_sdk.accept_license = true;

      my.unfree = [
        "androidsdk"
        "android-sdk-cmdline-tools"
        "android-sdk-platform-tools"
        "android-emulator"
        "cmdline-tools"
        "platform-tools"
        "platforms"
        "platform"
        "build-tools"
        "emulator"
        "addons"
        "extras"
        "patcher"
        "sources"
      ];
    };
}
