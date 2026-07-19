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

  # Terminais — fonte vem do fontconfig (theme.nix). Com stylix removido (veredito A
  # do mapa noctalia-shell), as cores base16 não são mais injetadas: foot/bat/btop/
  # etc. usam suas paletas default. Definir cores explícitas aqui se quiser matte-black.
  programs.foot = {
    enable = true;
    settings = {
      main.pad = "8x4";
      cursor = {
        style = "block";
        blink = "no";
      };
      key-bindings = {
        clipboard-copy = "Control+Shift+c Control+Insert";
        clipboard-paste = "Control+Shift+v Shift+Insert";
        # Shift+Insert por padrão cola o primary — libera pro clipboard-paste
        primary-paste = "none";
      };
    };
  };

  # programs.ghostty = {
  #   enable = true;
  #   settings = {
  #     font-style = "Regular";
  #     font-feature = "-calt";
  #     window-theme = "ghostty";
  #     window-padding-x = 8;
  #     window-padding-y = 4;
  #     confirm-close-surface = false;
  #     resize-overlay = "never";
  #     gtk-toolbar-style = "flat";
  #     cursor-style = "block";
  #     cursor-style-blink = false;
  #     shell-integration-features = "no-cursor,ssh-env";
  #     mouse-scroll-multiplier = 0.95;
  #     keybind = [
  #       "super+t=unbind"
  #       "shift+insert=paste_from_clipboard"
  #       "control+insert=copy_to_clipboard"
  #     ];
  #   };
  # };

  # conf do repo é lido em runtime — segue editável ao vivo, sem rebuild
  programs.tmux = {
    enable = true;
    sensibleOnTop = false;
    extraConfig = lib.mkAfter "source-file ${dotfiles}/tmux/tmux.conf";
  };

  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ./starship.toml);
  };

  # Ferramentas de terminal (usam paleta default agora que o stylix saiu)
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

  # Terminal padrão do KDE (o xdg-terminals.list cobre o xdg-terminal-exec)
  programs.plasma.configFile."kdeglobals"."General" = {
    "TerminalApplication".value = "foot";
    "TerminalService".value = "foot.desktop";
  };

  home.file.".zshrc".source = link "${dotfiles}/shell/.zshrc";
  xdg.configFile."fastfetch".source = link "${dotfiles}/fastfetch";
  xdg.configFile."xdg-terminals.list".source = link "${dotfiles}/shell/xdg-terminals.list";
}
