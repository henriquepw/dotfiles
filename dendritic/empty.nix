{ ... }:
{
  flake.nixosModules.name =
    { pkgs, ... }:
    {
      programs.name = {
        enable = true;
        package = pkgs.hello;
      };

      environment.systemPackages = [
        pkgs.foo
      ];

      home-manager.sharedModules = [
        (
          {
            config,
            repoRoot,
            link,
            ...
          }:
          { }
        )
      ];
    };
}
