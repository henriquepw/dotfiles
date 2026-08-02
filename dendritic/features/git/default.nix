{ ... }:
{
  flake.nixosModules.git =
    { pkgs, ... }:
    {
      programs.git.enable = true;
      programs.lazygit.enable = true;

      environment.systemPackages = [
        pkgs.gh
      ];

      home-manager.sharedModules = [
        (
          {
            config,
            repoRoot,
            link,
            ...
          }:
          {
            xdg.configFile."git".source = link "${repoRoot}/dendritic/features/git/config/git";
            home.file.".local/bin/git-fetch.sh".source = link "${repoRoot}/dendritic/features/git/config/bin/git-fetch.sh";
          }
        )
      ];
    };
}
