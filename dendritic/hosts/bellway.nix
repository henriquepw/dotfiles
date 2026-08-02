{ self, inputs, ... }:
{
  flake.nixosConfigurations.bellway = inputs.nixpkgs.lib.nixosSystem {
    modules = with self.nixosModules; [
      inputs.home-manager.nixosModules.home-manager
      base
      git
      nvim
      terminal
    ];
  };
}
