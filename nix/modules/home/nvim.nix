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
    # efm via nix — o binário do mason não é confiável no NixOS
    efm-langserver
    # nvim-treesitter (branch main) compila parsers no :TSUpdate — precisa do
    # CLI e de um compilador C
    tree-sitter
    gcc
  ];
  xdg.configFile."nvim".source = link "${dotfiles}/nvim";
}
