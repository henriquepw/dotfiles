{
  pkgs,
  config,
  dotfiles,
  ...
}:
{
  home.packages = with pkgs; [
    git
    lazygit
  ];
  xdg.configFile."git".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/git";
}
