{ ... }:
{
  flake.nixosModules.nvim =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.neovim
        pkgs.nil
        pkgs.nixfmt
        pkgs.statix
        pkgs.efm-langserver
        pkgs.tree-sitter
        pkgs.gcc
      ];

      environment.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };

      home-manager.sharedModules = [
        (
          {
            config,
            repoRoot,
            link,
            ...
          }:
          {
            xdg.configFile."nvim".source = link "${repoRoot}/dendritic/features/nvim/config";
          }
        )
      ];
    };
}
