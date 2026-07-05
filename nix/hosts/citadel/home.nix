{ config, ... }:
{
  imports = [ ../../modules/home ];

  # Caminho estável pro repo — o Makefile/setup.sh mantém ~/.dotfiles
  # apontando pro clone atual, onde quer que ele esteja
  _module.args.dotfiles = "${config.home.homeDirectory}/.dotfiles/dotfiles";

  home = {
    username = "henrique";
    homeDirectory = "/home/henrique";
    stateVersion = "24.11";
  };
}
