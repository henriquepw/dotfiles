{
  pkgs,
  config,
  repoRoot,
  ...
}:
let
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  home.packages = with pkgs; [
    git
    gh
  ];

  programs.lazygit.enable = true;
  xdg.configFile."git".source = link "${repoRoot}/modules/git/config/git";
  home.file.".local/bin/git-fetch.sh".source = link "${repoRoot}/modules/git/config/bin/git-fetch.sh";
}
