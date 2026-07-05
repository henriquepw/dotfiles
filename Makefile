SETUP_SCRIPT := scripts/setup.sh

all: help

.PHONY: help
help:
	@echo
	@echo "Choose a make command to run"
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo

## install: full setup
.PHONY: install
install:
	@echo "▶ Running full setup"
	@bash $(SETUP_SCRIPT)

## rebuild: apply current NixOS configuration
.PHONY: rebuild
rebuild:
	@sudo nixos-rebuild switch --flake ./nix#citadel

## update: update flake inputs and apply configuration
.PHONY: update
update:
	@nix flake update --flake ./nix
	@sudo nixos-rebuild switch --flake ./nix#citadel
