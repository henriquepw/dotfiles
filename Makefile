SETUP_SCRIPT := scripts/setup.sh

all: help

.PHONY: help
help:
	@echo
	@echo "Choose a make command to run"
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo

# a config nix referencia o repo via ~/.dotfiles, então o clone pode viver em qualquer pasta
.PHONY: link
link:
	@ln -sfn $(CURDIR) $$HOME/.dotfiles

## install: full setup
.PHONY: install
install:
	@echo "▶ Running full setup"
	@bash $(SETUP_SCRIPT)

## rebuild: apply current NixOS configuration
.PHONY: rebuild
rebuild: link
	@sudo nixos-rebuild switch --flake ./nix#citadel

## update: update flake inputs and apply configuration
.PHONY: update
update: link
	@nix flake update --flake ./nix
	@sudo nixos-rebuild switch --flake ./nix#citadel
