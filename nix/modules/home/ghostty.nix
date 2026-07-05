{
  pkgs,
  config,
  dotfiles,
  ...
}:
{
  home.packages = [ pkgs.ghostty ];
  xdg.configFile."ghostty".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/ghostty";
}
