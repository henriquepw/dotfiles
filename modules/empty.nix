{ ... }:
{
  flake.nixosModules.name =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.foo
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
