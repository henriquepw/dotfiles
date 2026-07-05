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
    neovim
    nil
    nixfmt
    statix
  ];
  xdg.configFile."nvim".source = link "${dotfiles}/nvim";
}
