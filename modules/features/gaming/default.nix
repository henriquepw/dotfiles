{ ... }:
{
  flake.nixosModules.gaming =
    { pkgs, ... }:
    {
      hardware.display = {
        edid.modelines = {
          "DP3_4K60" = "533.00 3840 3888 3920 4000 2160 2163 2168 2222 +hsync -vsync";
        };
        outputs."DP-3" = {
          edid = "DP3_4K60.bin";
          mode = "e"; # force the output enabled, skipping amdgpu checks
        };
      };

      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = false;
        gamescopeSession.enable = false;
        extraCompatPackages = with pkgs; [ proton-ge-bin ];
      };

      programs.gamemode = {
        enable = true;
        settings = {
          general = {
            renice = 10; # prioritize the game process
          };
        };
      };

      programs.gamescope = {
        enable = true;
        capSysNice = true;
      };

      # Sunshine — setcap binary (KMS capture + uinput on Wayland)
      services.sunshine = {
        enable = true;
        capSysAdmin = true;
        autoStart = true;
        openFirewall = true;
      };

      environment.systemPackages = with pkgs; [
        discord
        faugus-launcher
        lutris
        protonup-qt
        mangohud
        kdePackages.krfb
      ];

      environment.sessionVariables.SDL_VIDEODRIVER = "wayland";

      home-manager.sharedModules = [
        (
          {
            pkgs,
            featurePath,
            link,
            ...
          }:
          {
            xdg.configFile."sunshine".source = link "${featurePath}/gaming/config/sunshine";

            # override the packaged entry: launching the binary conflicts with the user service
            xdg.desktopEntries."dev.lizardbyte.app.Sunshine" = {
              name = "Sunshine";
              comment = "Open the Sunshine web UI";
              exec = "${pkgs.xdg-utils}/bin/xdg-open https://localhost:47990";
              icon = "dev.lizardbyte.app.Sunshine";
              categories = [
                "RemoteAccess"
                "Network"
              ];
              terminal = false;
              settings.Keywords = "gamestream;stream;moonlight;remote play;";
            };

            xdg.configFile."autostart/steam.desktop".text = ''
              [Desktop Entry]
              Type=Application
              Name=Steam
              Exec=steam -silent %U
              Icon=steam
              Comment=Steam Game Launcher
              X-KDE-autostart-after=panel
            '';
          }
        )
      ];

      my.unfree = [
        "steam"
        "steam-original"
        "steam-unwrapped"
        "proton-ge-bin"
        "discord"
      ];
    };
}
