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
    # Terminals
    ghostty
    foot

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

    # Image viewers via sixel
    chafa
    libsixel

    # Dev productivity
    lazygit
    tmux
  ];

  # tpm instala os demais plugins em ~/.tmux/plugins via prefix+I
  home.file.".tmux/plugins/tpm".source = pkgs.fetchFromGitHub {
    owner = "tmux-plugins";
    repo = "tpm";
    rev = "v3.1.0";
    hash = "sha256-CeI9Wq6tHqV68woE11lIY4cLoNY8XWyXyMHTDmFKJKI=";
  };

  home.file.".zshrc".source = link "${dotfiles}/shell/.zshrc";
  xdg.configFile."fastfetch".source = link "${dotfiles}/fastfetch";
  xdg.configFile."foot".source = link "${dotfiles}/foot";
  xdg.configFile."ghostty".source = link "${dotfiles}/ghostty";
  xdg.configFile."starship.toml".source = link "${dotfiles}/shell/starship.toml";
  xdg.configFile."xdg-terminals.list".source = link "${dotfiles}/shell/xdg-terminals.list";
  xdg.configFile."tmux".source = link "${dotfiles}/tmux";
}
