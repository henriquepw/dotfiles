{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Office
    onlyoffice-desktopeditors

    # 3D printing
    orca-slicer

    # Dev tools
    nodejs
    bun
    go
    zig
    rustup
  ];
}
