{ pkgs, ... }:
{
  # vicinae roda como serviço de usuário nas duas sessões (KDE e KineticWE) —
  # por isso vive fora do kde.nix. O flake module deixa o target vicinae do
  # stylix aplicar o tema. O atalho de toggle específico do Plasma
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
