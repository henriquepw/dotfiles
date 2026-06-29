{ pkgs, ... }:
{
  home.packages = with pkgs; [
    zsh
    starship
    gnumake
    ripgrep
    fd
    jq

    # System monitoring
    btop

    # File tools
    delta
    tree
    unzip
    zoxide
    fzf
    bat

    # Dev productivity
    lazygit
    tmux
  ];
  home.file.".zshrc".source = ./.zshrc;
  xdg.configFile."starship.toml".source = ./starship.toml;
  xdg.configFile."xdg-terminals.list".source = ./xdg-terminals.list;
  xdg.configFile."tmux".source = ./tmux;
}
