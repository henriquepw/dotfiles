{
  pkgs,
  config,
  lib,
  repoRoot,
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

  # foot.ini is symlinked from the repo, read at runtime — live-editable, no rebuild.
  programs.foot.enable = true;
  xdg.configFile."foot/foot.ini".source = link "${repoRoot}/modules/terminal/config/foot/foot.ini";

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

  # tmux.conf is sourced from the repo at runtime — live-editable, no rebuild.
  programs.tmux = {
    enable = true;
    sensibleOnTop = false;
    extraConfig = lib.mkAfter "source-file ${repoRoot}/modules/terminal/config/tmux/tmux.conf";
  };

  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ./config/starship.toml);
  };

  programs.bat.enable = true;
  programs.btop.enable = true;
  programs.fzf.enable = true;

  # tpm installs the remaining plugins into ~/.tmux/plugins via prefix+I.
  home.file.".tmux/plugins/tpm".source = pkgs.fetchFromGitHub {
    owner = "tmux-plugins";
    repo = "tpm";
    rev = "v3.1.0";
    hash = "sha256-CeI9Wq6tHqV68woE11lIY4cLoNY8XWyXyMHTDmFKJKI=";
  };

  # KDE default terminal (xdg-terminals.list covers xdg-terminal-exec).
  programs.plasma.configFile."kdeglobals"."General" = {
    "TerminalApplication".value = "foot";
    "TerminalService".value = "foot.desktop";
  };

  home.file.".zshrc".source = link "${repoRoot}/modules/terminal/config/shell/.zshrc";
  xdg.configFile."fastfetch".source = link "${repoRoot}/modules/terminal/config/fastfetch";
  xdg.configFile."xdg-terminals.list".source = link "${repoRoot}/modules/terminal/config/shell/xdg-terminals.list";
}
