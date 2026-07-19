{ config, ... }:
{
  imports = [ ../../modules/home ];

  # Stable repo path — Makefile/setup.sh keeps ~/.dotfiles pointing at the current clone
  _module.args.dotfiles = "${config.home.homeDirectory}/.dotfiles/dotfiles";

  home = {
    username = "henrique";
    homeDirectory = "/home/henrique";
    stateVersion = "24.11";
  };
}
