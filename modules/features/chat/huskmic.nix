{ ... }:
{
  flake.nixosModules.hushmic =
    { inputs, pkgs, ... }:
    {
      environment.systemPackages = [
        inputs.hushmic.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
}
