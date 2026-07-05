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
  home.packages = [ pkgs.brave ];
  xdg.configFile."brave-flags.conf".source = link "${dotfiles}/brave/brave-flags.conf";
  xdg.configFile."brave-origin-beta-flags.conf".source =
    link "${dotfiles}/brave/brave-origin-beta-flags.conf";
}
