{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Office
    onlyoffice-desktopeditors

    # 3D printing
    orca-slicer

    # Launcher
    vicinae

    # Dev tools
    nodejs
    bun
    go
    zig
    rustup

    # Fonts
    nerd-fonts.jetbrains-mono
  ];
}
