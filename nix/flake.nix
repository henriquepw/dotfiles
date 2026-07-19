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
    # Noctalia v5 é o shell (bar/notif/tray/wallpaper) rodando sobre o kwin_wayland
    # da sessão Plasma. NÃO forçar nixpkgs.follows: seguir nixpkgs desabilitaria o
    # cache binário do projeto e forçaria compilar o binário C++ nativo localmente.
    # O cache vem do noctalia.cachix.org (nix.settings no host).
    noctalia.url = "github:noctalia-dev/noctalia";
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
