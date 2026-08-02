{ ... }:
{
  flake.nixosModules.boot =
    { pkgs, ... }:
    {
      boot.loader = {
        systemd-boot.enable = true;
        systemd-boot.consoleMode = "max";
        efi.canTouchEfiVariables = true;
      };

      services.displayManager.ly = {
        enable = true;
        settings.xsessions = "";
      };

      services.xserver.xkb = {
        layout = "us";
        variant = "intl";
      };

      services.displayManager.sddm.enable = false;

      programs.dconf.enable = true;

      security.polkit.enable = true;
    };
}
