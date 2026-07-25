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
    # No nixpkgs.follows: it would disable the project's binary cache and force a local native build.
    noctalia.url = "github:noctalia-dev/noctalia";
    # Remote deploy for bellway (build on citadel, push closure over SSH, magic-rollback).
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      deploy-rs,
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

      nixosConfigurations.bellway = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs system; };
        modules = [ ./hosts/bellway ];
      };

      # Remote deploy from citadel: build locally on citadel, push over SSH (LAN or wt0),
      # magic-rollback auto-reverts (~30s) if bellway goes unreachable after activation.
      deploy.nodes.bellway = {
        hostname = "10.10.0.1";
        profiles.system = {
          user = "root";
          sshUser = "admin";
          path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.bellway;
          magicRollback = true;
          autoRollback = true;
        };
      };

      # `nix flake check` validates the deploy config.
      checks = builtins.mapAttrs (_: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
