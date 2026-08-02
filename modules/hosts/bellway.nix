{ self, inputs, ... }:
# bellway — headless NixOS edge router + DNS/adblock resolver (HP ProBook 640 G1).
{
  flake.nixosConfigurations.bellway = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      inputs.home-manager.nixosModules.home-manager
      base

      (
        { pkgs, ... }:
        {
          imports = [ ../_hardware/bellway/hardware-configuration.nix ];

          _module.args.user = "admin";

          networking.hostName = "bellway";

          # Bootloader — UEFI + systemd-boot (matches citadel).
          boot.loader = {
            systemd-boot.enable = true;
            efi.canTouchEfiVariables = true;
          };

          # Admin login — wheel only, no desktop groups. citadel's key added for remote deploy/SSH.
          users.users.admin = {
            isNormalUser = true;
            extraGroups = [ "wheel" ];
            shell = pkgs.zsh;
            initialPassword = "changeme";
            openssh.authorizedKeys.keys = [
              # TODO on-device: paste citadel's public SSH key so deploy-rs/SSH works
            ];
          };

          services.openssh = {
            enable = true;
            settings = {
              PasswordAuthentication = false;
              PermitRootLogin = "prohibit-password";
            };
          };

          # Always-on server posture — never suspend a plugged-in gateway.
          services.logind.settings.Login = {
            HandleLidSwitch = "ignore";
            HandleLidSwitchExternalPower = "ignore";
            HandleLidSwitchDocked = "ignore";
          };
          systemd.targets.sleep.enable = false;
          systemd.targets.suspend.enable = false;
          systemd.targets.hibernate.enable = false;
          systemd.targets.hybridSleep.enable = false;
          # No power-profiles-daemon — a plugged-in gateway wants full performance.
          # The laptop battery doubles as a free UPS (automatic, no config).

          # Reliability & ops (§8).
          services.journald.extraConfig = ''
            Storage=persistent
            SystemMaxUse=500M
            SystemMaxFileSize=50M
          '';

          # Hardware watchdog (Haswell iTCO) — a hard kernel hang auto-reboots the unattended box.
          systemd.settings.Manager.RuntimeWatchdogSec = "20s";

          hardware.enableRedistributableFirmware = true;

          system.stateVersion = "26.05";
        }
      )

      git
      nvim
      terminal
      router
    ];
  };
}
