{ ... }:
{
  flake.nixosModules.theme =
    { pkgs, ... }:
    {
      fonts.packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
        nerd-fonts.jetbrains-mono
      ];

      home-manager.sharedModules = [
        (
          { config, pkgs, ... }:
          {
            home.pointerCursor = {
              name = "breeze_cursors";
              package = pkgs.kdePackages.breeze;
              size = 24;
              gtk.enable = true;
              x11.enable = true;
            };

            fonts.fontconfig = {
              enable = true;
              defaultFonts = {
                monospace = [ "JetBrainsMono Nerd Font Mono" ];
                sansSerif = [ "JetBrainsMono Nerd Font Propo" ];
                serif = [ "JetBrainsMono Nerd Font Propo" ];
                emoji = [ "Noto Color Emoji" ];
              };
            };

            gtk = {
              enable = true;
              font = {
                name = "JetBrainsMono Nerd Font Propo";
                size = 10;
              };
              iconTheme = {
                name = "Papirus-Dark";
                package = pkgs.papirus-icon-theme.override { color = "orange"; };
              };
              gtk3.extraConfig."gtk-application-prefer-dark-theme" = true;
              gtk4.extraConfig."gtk-application-prefer-dark-theme" = true;
              gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
            };
          }
        )
      ];
    };
}
