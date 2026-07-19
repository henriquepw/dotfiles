{ pkgs, ... }:
{
  # vicinae roda como user service na sessão Plasma (sem o hack do kineticwe que
  # injetava env wayland — some junto com o kineticwe.nix). O atalho de toggle
  # (services/vicinae.desktop = Meta+Return) fica no kde.nix.
  programs.vicinae = {
    enable = true;
    package = pkgs.vicinae;
    systemd = {
      enable = true;
      autoStart = true;
    };
  };
}
