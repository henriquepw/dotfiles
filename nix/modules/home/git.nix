{
  pkgs,
  config,
  dotfiles,
  ...
}:
let
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  home.packages = with pkgs; [
    git
    lazygit
  ];
  xdg.configFile."git".source = link "${dotfiles}/git";
  home.file.".local/bin/git-fetch.sh".source = link "${dotfiles}/bin/git-fetch.sh";
}
