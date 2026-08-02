{ ... }:
{
  flake.nixosModules.autoUpdate =
    {
      config,
      pkgs,
      user,
      ...
    }:
    let
      repo = "/home/${user}/.dotfiles";
      nix = "${config.nix.package}/bin/nix";
    in
    {
      systemd.services.nixos-autoupdate = {
        description = "Weekly flake update + nixos-rebuild switch";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        startAt = "weekly";

        serviceConfig.Type = "oneshot";
        environment = {
          HOME = "/root";
        }

        // config.networking.proxy.envVars;
        path = [
          pkgs.coreutils
          pkgs.util-linux
          pkgs.gitMinimal
          config.nix.package
          config.programs.ssh.package
        ];

        script = ''
          set -eu
          # Update inputs as the user so flake.lock stays user-owned.
          runuser -u ${user} -- env HOME=/home/${user} ${nix} flake update --flake ${repo}
          ${config.system.build.nixos-rebuild}/bin/nixos-rebuild switch --flake ${repo}#${config.networking.hostName}
        '';
      };

      # Catch up if the machine was off at the scheduled time; spread the load.
      systemd.timers.nixos-autoupdate.timerConfig = {
        Persistent = true;
        RandomizedDelaySec = "1h";
      };
    };
}
