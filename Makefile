SETUP_SCRIPT := scripts/setup.sh

# host to build; defaults to the current machine's hostname, override with `make rebuild HOST=bellway`
HOST ?= $(shell hostname)

all: help

.PHONY: help
help:
	@echo
	@echo "Choose a make command to run (override host with HOST=<name>)"
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo

# a config nix referencia o repo via ~/.dotfiles, então o clone pode viver em qualquer pasta
.PHONY: link
link:
	@ln -sfn $(CURDIR) $$HOME/.dotfiles

## install: full setup for HOST (default: current hostname)
.PHONY: install
install:
	@echo "▶ Running full setup for $(HOST)"
	@bash $(SETUP_SCRIPT) $(HOST)

## rebuild: apply NixOS configuration for HOST (default: current hostname)
.PHONY: rebuild
rebuild: link
	@sudo nixos-rebuild switch --flake .#$(HOST)

## update: update flake inputs and apply configuration for HOST
.PHONY: update
update: link
	@nix flake update --flake .
	@sudo nixos-rebuild switch --flake .#$(HOST)
