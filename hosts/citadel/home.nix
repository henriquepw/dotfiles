{ config, ... }:
{
  imports = [ ../../modules ];

  # Stable repo path — Makefile/setup.sh keeps ~/.dotfiles pointing at the current clone
  _module.args.repoRoot = "${config.home.homeDirectory}/.dotfiles";

  home = {
    username = "henrique";
    homeDirectory = "/home/henrique";
    stateVersion = "24.11";
  };
}
