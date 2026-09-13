{ ... }:
{
  flake.nixosModules.browser =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        brave-origin
      ];

      home-manager.sharedModules = [
        (
          {
            config,
            lib,
            pkgs,
            inputs,
            featurePath,
            link,
            ...
          }:
          {
            xdg.configFile."brave-flags.conf".source = link "${featurePath}/browser/config/brave-flags.conf";

            xdg.configFile."brave-origin-flags.conf".source =
              link "${featurePath}/browser/config/brave-flags.conf";

            home.sessionVariables = {
              BROWSER = "brave-origin";
              GTK_IM_MODULE = "cedilla";
              QT_IM_MODULE = "cedilla";
            };
          }
        )
      ];
    };
}
