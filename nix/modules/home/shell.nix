{
  pkgs,
  config,
  dotfiles,
  ...
}:
let
  link = config.lib.file.mkOutOfStoreSymlink;
in
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
    fastfetch

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
  home.file.".zshrc".source = link "${dotfiles}/shell/.zshrc";
  xdg.configFile."fastfetch".source = link "${dotfiles}/fastfetch";
  xdg.configFile."starship.toml".source = link "${dotfiles}/shell/starship.toml";
  xdg.configFile."xdg-terminals.list".source = link "${dotfiles}/shell/xdg-terminals.list";
  xdg.configFile."tmux".source = link "${dotfiles}/tmux";
}
