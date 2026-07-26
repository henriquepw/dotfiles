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
    neovim
    nil
    nixfmt
    statix
    efm-langserver
    tree-sitter
    gcc
  ];
  xdg.configFile."nvim".source = link "${repoRoot}/modules/nvim/config";
}
