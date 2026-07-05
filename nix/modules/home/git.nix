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
}
