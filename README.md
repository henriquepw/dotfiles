Para usar: você precisará adicionar o hardware-configuration.nix da máquina (gerado por nixos-generate-config) em hosts/citadel/ e rodar:
sudo nixos-rebuild switch --flake .#citadel
