SETUP_SCRIPT := scripts/setup.sh
STOW_PACKAGES := .config .local
BACKUP_ROOT ?= $(HOME)/.dotfiles-backups/$(shell date +%Y%m%d-%H%M%S)

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

## stow: backup existing files and install dotfiles as symlinks
.PHONY: stow
stow: guard
	@set -eu; \
	echo "▶ Backing up conflicting files to $(BACKUP_ROOT)"; \
	for package in $(STOW_PACKAGES); do \
		find "$$package" \( -type f -o -type l \) -print | while read -r source; do \
			relative="$${source#$$package/}"; \
			target="$(HOME)/$$package/$${relative}"; \
		if [ -L "$$target" ] && [ "$$(readlink -f "$$target")" = "$$(readlink -f "$$source")" ]; then \
			continue; \
		fi; \
		if [ -e "$$target" ] || [ -L "$$target" ]; then \
			backup="$(BACKUP_ROOT)/$$package/$${relative}"; \
			mkdir -p "$$(dirname "$$backup")"; \
			mv "$$target" "$$backup"; \
			echo "  $$target -> $$backup"; \
		fi; \
		done; \
	done; \
	if [ -L "$(HOME)/.zshrc" ] && [ "$$(readlink -f "$(HOME)/.zshrc")" = "$$(readlink -f "$(CURDIR)/.zshrc")" ]; then \
		:; \
	elif [ -e "$(HOME)/.zshrc" ] || [ -L "$(HOME)/.zshrc" ]; then \
		mkdir -p "$(BACKUP_ROOT)"; \
		mv "$(HOME)/.zshrc" "$(BACKUP_ROOT)/.zshrc"; \
		echo "  $(HOME)/.zshrc -> $(BACKUP_ROOT)/.zshrc"; \
	fi; \
	echo "▶ Running stow"; \
	mkdir -p "$(HOME)/.config" "$(HOME)/.local"; \
	stow --dir="$(CURDIR)/.config" --target="$(HOME)/.config" --restow --no-folding -v .; \
	stow --dir="$(CURDIR)/.local" --target="$(HOME)/.local" --restow --no-folding -v .; \
	ln -sfn "$(CURDIR)/.zshrc" "$(HOME)/.zshrc"; \
	echo "▶ Backup: $(BACKUP_ROOT)"

## uninstall: unstow dotfiles
.PHONY: uninstall
uninstall: guard
	@echo "▶ Unstowing dotfiles"
	@stow -D --no-folding -v -t "$(HOME)" $(STOW_PACKAGES)
	@if [ -L "$(HOME)/.zshrc" ] && [ "$$(readlink "$(HOME)/.zshrc")" = "$(CURDIR)/.zshrc" ]; then \
		rm "$(HOME)/.zshrc"; \
	fi
