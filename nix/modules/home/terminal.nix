{
  pkgs,
  config,
  lib,
  dotfiles,
  ...
}:
let
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  home.packages = with pkgs; [
    zsh
    gnumake
    ripgrep
    fd
    jq

    # System monitoring
    fastfetch

    # File tools
    delta
    tree
    unzip
    zoxide

    # Image viewers via sixel
    chafa
    libsixel
  ];

  # Terminais — cores e fonte vêm do stylix
  programs.foot = {
    enable = true;
    settings = {
      main.pad = "8x4";
      cursor = {
        style = "block";
        blink = "no";
      };
      # Mesmos atalhos de clipboard do ghostty (mantendo os padrões Ctrl+Shift)
      key-bindings = {
        clipboard-copy = "Control+Shift+c Control+Insert";
        clipboard-paste = "Control+Shift+v Shift+Insert";
        # Shift+Insert por padrão cola o primary — libera pro clipboard-paste
        primary-paste = "none";
      };
    };
  };

  programs.ghostty = {
    enable = true;
    settings = {
      font-style = "Regular";
      font-feature = "-calt";
      window-theme = "ghostty";
      window-padding-x = 8;
      window-padding-y = 4;
      confirm-close-surface = false;
      resize-overlay = "never";
      gtk-toolbar-style = "flat";
      cursor-style = "block";
      cursor-style-blink = false;
      shell-integration-features = "no-cursor,ssh-env";
      mouse-scroll-multiplier = 0.95;
      keybind = [
        "super+t=unbind"
        "shift+insert=paste_from_clipboard"
        "control+insert=copy_to_clipboard"
      ];
    };
  };

  # O stylix injeta os estilos (source-file do tema base16) antes do extraConfig
  programs.tmux = {
    enable = true;
    sensibleOnTop = false;
    extraConfig = lib.mkAfter (builtins.readFile ../../../dotfiles/tmux/tmux.conf);
  };

  # Paleta base16 do stylix entra por cima; o arquivo continua em dotfiles/
  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ../../../dotfiles/shell/starship.toml);
  };

  # Habilitados só pelo tema do stylix
  programs.bat.enable = true;
  programs.btop.enable = true;
  programs.fzf.enable = true;

  # tpm instala os demais plugins em ~/.tmux/plugins via prefix+I
  home.file.".tmux/plugins/tpm".source = pkgs.fetchFromGitHub {
    owner = "tmux-plugins";
    repo = "tpm";
    rev = "v3.1.0";
    hash = "sha256-CeI9Wq6tHqV68woE11lIY4cLoNY8XWyXyMHTDmFKJKI=";
  };

  home.file.".zshrc".source = link "${dotfiles}/shell/.zshrc";
  xdg.configFile."fastfetch".source = link "${dotfiles}/fastfetch";
  xdg.configFile."xdg-terminals.list".source = link "${dotfiles}/shell/xdg-terminals.list";
}
