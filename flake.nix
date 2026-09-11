{
  description = "Henrique's NixOS configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    # Only for packages missing from stable
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

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

    hushmic.url = "github:Fovty/hushmic-nix";
  };
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
