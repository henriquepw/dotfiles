{ ... }:
{
  flake.nixosModules.git =
    { pkgs, ... }:
    {
      programs.git.enable = true;
      programs.lazygit.enable = true;

      environment.systemPackages = with pkgs; [
        gh
      ];

      home-manager.sharedModules = [
        (
          {
            config,
            featurePath,
            link,
            ...
          }:
          {
            xdg.configFile."git".source = link "${featurePath}/git/config/git";
            home.file.".local/bin/git-fetch.sh".source = link "${featurePath}/git/config/bin/git-fetch.sh";
          }
        )
      ];
    };
}
