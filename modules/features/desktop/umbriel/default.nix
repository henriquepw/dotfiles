{ ... }:
{
  flake.nixosModules.umbriel =
    { inputs, pkgs, ... }:
    {
      imports = [ inputs.umbriel.nixosModules.default ];

      nixpkgs.overlays = [ (import ./_overlays.nix) ];

      programs.umbriel.enable = true;

      environment.systemPackages = with pkgs; [
        jq
        xwayland-satellite
      ];

      # umbriel forks xwayland-satellite as its own child instead of a systemd unit, so a
      # restart of umbriel.service (without a full reboot) can leave a stale :0 socket behind;
      # umbriel then disables xwayland entirely instead of retrying another display number.
      systemd.user.services.umbriel.serviceConfig.ExecStartPre = [
        "${pkgs.coreutils}/bin/rm -f /tmp/.X11-unix/X0"
      ];

      home-manager.sharedModules = [
        (
          {
            inputs,
            featurePath,
            link,
            ...
          }:
          {
            imports = [ inputs.umbriel.homeModules.default ];

            programs.umbriel = {
              enable = true;
              package = null;
              settings = link "${featurePath}/desktop/umbriel/config/config.toml";
            };
          }
        )
      ];
    };
}
