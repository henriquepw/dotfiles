{ config, ... }:
{
  imports = [ ../../modules/home ];

  # Onde o repo está clonado — os módulos criam symlinks apontando pra cá
  _module.args.dotfiles = "${config.home.homeDirectory}/git/henriquepw/new/dotfiles/dotfiles";

  home = {
    username = "henrique";
    homeDirectory = "/home/henrique";
    stateVersion = "24.11";
  };
}
