{ self, inputs, ... }:
{
  flake.nixosConfigurations.citadel = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit inputs; };
        home-manager.users.henrique.home.stateVersion = "24.11";
      }
      base

      (
        { pkgs, ... }:
        {
          imports = [ ../_hardware/citadel/hardware-configuration.nix ];

          _module.args.user = "henrique";

          boot.kernelParams = [
            "quiet"
            "loglevel=3"
            "rd.udev.log_level=3"
            "udev.log_priority=3"
            "video=DP-1:2560x1440@165"
          ];

          networking.hostName = "citadel";

          users.users.henrique = {
            initialPassword = "123";
            isNormalUser = true;
            extraGroups = [
              "wheel"
              "networkmanager"
              "video"
              "audio"
              "input"
            ];
            shell = pkgs.zsh;
          };

          system.stateVersion = "24.11";
        }
      )

      boot
      audio
      bluetooth
      network
      power
      tailscale
      keyd
      gpuamd
      gaming
      browser
      develop
      git
      kde
      noctalia
      nvim
      office
      print
      syncthing
      terminal
      theme
    ];
  };
}
