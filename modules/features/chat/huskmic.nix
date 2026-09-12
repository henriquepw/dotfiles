{ ... }:
{
  flake.nixosModules.hushmic =
    { inputs, pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      hushmic = inputs.hushmic.packages.${system}.default;
    in
    {
      environment.systemPackages = [
        (hushmic.override {
          xorg = {
            libX11 = pkgs.libx11;
            libXcursor = pkgs.libxcursor;
            libXi = pkgs.libxi;
            libXrandr = pkgs.libxrandr;
            libxcb = pkgs.libxcb;
          };
        })
      ];
    };
}
