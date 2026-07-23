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
    gh
  ];

  programs.lazygit.enable = true;
  xdg.configFile."git".source = link "${dotfiles}/git";
  home.file.".local/bin/git-fetch.sh".source = link "${dotfiles}/bin/git-fetch.sh";
}
