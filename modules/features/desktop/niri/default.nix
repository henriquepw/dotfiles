{ ... }:
{
  flake.nixosModules.niri =
    { pkgs, ... }:
    {
      programs.niri.enable = true;
      programs.niri.useNautilus = true;

      environment.systemPackages = with pkgs; [
        jq
        xwayland-satellite
      ];

      home-manager.sharedModules = [
        (
          {
            config,
            link,
            featurePath,
            ...
          }:
          {
            xdg.configFile."niri".source = link "${featurePath}/niri/config";
            home.file.".local/bin/toggle-tv".source = link "${featurePath}/niri/config/bin/toggle-tv";
          }
        )
      ];
    };
}
