{ ... }:
{
  flake.nixosModules.name =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        foo
      ];

      home-manager.sharedModules = [
        (
          {
            config,
            link,
            featurePath,
            ...
          }:
          { }
        )
      ];
    };
}
