{ ... }:
{
  flake.nixosModules.terminal =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
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

      home-manager.sharedModules = [
        (
          {
            config,
            repoRoot,
            link,
            lib,
            ...
          }:
          {
            programs.foot.enable = true;
            xdg.configFile."foot/foot.ini".source = link "${repoRoot}/dendritic/features/terminal/config/foot/foot.ini";

            # tmux.conf is sourced from the repo at runtime — live-editable, no rebuild.
            programs.tmux = {
              enable = true;
              sensibleOnTop = false;
              extraConfig = lib.mkAfter "source-file ${repoRoot}/dendritic/features/terminal/config/tmux/tmux.conf";
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

            home.file.".zshrc".source = link "${repoRoot}/dendritic/features/terminal/config/shell/.zshrc";
            xdg.configFile."fastfetch".source = link "${repoRoot}/dendritic/features/terminal/config/fastfetch";
            xdg.configFile."xdg-terminals.list".source =
              link "${repoRoot}/dendritic/features/terminal/config/shell/xdg-terminals.list";
          }
        )
      ];
    };
}
