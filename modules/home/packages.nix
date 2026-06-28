{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # CLI utilities
    ripgrep
    fd
    jq

    # Office
    onlyoffice-desktopeditors

    # Misc
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
