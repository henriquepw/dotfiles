{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Office
    onlyoffice-desktopeditors

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
