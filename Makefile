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

guard:
	@test -f .stow-local-ignore || \
	  (echo "Run make from dotfiles root" && exit 1)

## stow: run only the stow
.PHONY: stow
stow: guard
	@echo "▶ Running stow"
	@stow -v -t $$HOME */

## uninstall: unstow dotfiles
.PHONY: uninstall
uninstall: guard
	@echo "▶ Unstowing dotfiles"
	@stow -D -v -t $$HOME */

