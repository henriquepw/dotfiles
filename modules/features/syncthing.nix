{ ... }:
{
  flake.nixosModules.syncthing =
    { config, pkgs, user, ... }:
    let
      home = config.users.users.${user}.home;
    in
    {
      services.syncthing = {
        inherit user;
        enable = true;
        openDefaultPorts = true;
        guiAddress = "0.0.0.0:8384";
        group = "users";
        dataDir = home;
        configDir = "${home}/.config/syncthing";
      };

      # openDefaultPorts only opens sync ports, not the GUI
      networking.firewall.allowedTCPPorts = [ 8384 ];
    };
}
