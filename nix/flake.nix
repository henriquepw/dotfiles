{
  description = "Henrique's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vicinae = {
      url = "github:vicinaehq/vicinae";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # NÃO forçar nixpkgs.follows: o kineticwe traz seu próprio nixpkgs-unstable
    # (Qt 6.10 / KF6 6.26 pré-buildados) e sua overlay é aditiva — só adiciona
    # kineticwe/kwin-we/noctalia, não sobrescreve qt6/kdePackages, então o Plasma
    # do sistema não é rebuildado.
    kineticwe.url = "gitlab:theblackdon/kineticwe";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.citadel = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs system; };
        modules = [ ./hosts/citadel ];
      };
    };
}
