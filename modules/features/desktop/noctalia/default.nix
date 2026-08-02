{ ... }:
{
  flake.nixosModules.noctalia =
    { pkgs, ... }:
    {
      # cache binário do noctalia — a feature dona do cache o declara
      nix.settings = {
        extra-substituters = [ "https://noctalia.cachix.org" ];
        extra-trusted-public-keys = [
          "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
        ];
      };

      home-manager.sharedModules = [
        (
          {
            inputs,
            pkgs,
            featurePath,
            link,
            ...
          }:
          {
            imports = [ inputs.noctalia.homeModules.default ];

            programs.noctalia = {
              enable = true;
              package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
              systemd.enable = true;
            };

            xdg.configFile."noctalia".source = link "${featurePath}/desktop/noctalia/config";
          }
        )
      ];
    };
}
