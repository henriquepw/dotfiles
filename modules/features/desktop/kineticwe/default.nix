{ inputs, ... }:
{
  flake.nixosModules.kineticwe =
    { ... }:
    {
      # nixosModules.default applies the kineticwe overlay and registers the
      # Wayland session (services.displayManager.sessionPackages).
      imports = [ inputs.kineticwe.nixosModules.default ];

      programs.kineticwe.enable = true;
    };
}
