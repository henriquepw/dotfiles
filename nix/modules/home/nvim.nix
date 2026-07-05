{
  pkgs,
  config,
  dotfiles,
  ...
}:
{
  home.packages = with pkgs; [
    neovim
    nil
    nixfmt
    statix
  ];
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/nvim";
}
