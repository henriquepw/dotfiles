all: help

.PHONY: help
help:
	@echo
	@echo "Choose a make command to run"
	@echo
	@sed -n 's/^##//p' $(MAKEFILE_LIST) | column -t -s ':' |  sed -e 's/^/ /'
	@echo

## link: remove links antigos da imagem citadel e linka os dotfiles em $HOME
.PHONY: link
link:
	@find "$$HOME" -xdev -maxdepth 3 -type l -lname '/usr/share/citadel-dotfiles/*' -print -delete
	@stow --target="$$HOME" --restow .

## check: mostra o que o stow faria, sem alterar nada
.PHONY: check
check:
	@stow --target="$$HOME" --no --verbose --restow .

## unlink: remove os links dos dotfiles de $HOME
.PHONY: unlink
unlink:
	@stow --target="$$HOME" --delete .
