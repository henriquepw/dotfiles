# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Every top-level directory (except `scripts/` and hidden meta-files) is a stow package that gets symlinked into `$HOME`.

## Branches

| Branch | Target OS |
|--------|-----------|
| `mac`  | macOS (main/default) |
| `nixos` | Fedora/NixOS Linux |
| `omarchy` | Arch-based |

When making changes, confirm which branch/OS is in scope before editing configs that differ across platforms.

## Key commands

### NixOS (primary — `nixos` branch)

```bash
sudo nixos-rebuild switch --flake .#citadel   # apply system + home-manager config
home-manager switch --flake .#citadel         # apply only home-manager (no sudo)
nix flake update                              # update flake.lock
```

### Stow (legacy — `mac`/`linux` branches)

```bash
make install   # full setup: installs packages + runs stow
make stow      # symlink dotfiles into $HOME (must run from repo root)
make uninstall # remove symlinks with stow -D
```

## NixOS structure

```
flake.nix                        # entry point; defines citadel nixosConfiguration
hosts/citadel/
  default.nix                    # NixOS system config: keyd, ibus, networking, users
  home.nix                       # home-manager top-level (imports modules/home)
  hardware-configuration.nix     # machine-generated, not tracked in git
modules/home/
  default.nix                    # imports all home modules
  git.nix                        # programs.git
  shell.nix                      # programs.zsh + starship + zoxide + fzf
  tmux.nix                       # programs.tmux (plugins managed by nix, no TPM)
  nvim.nix                       # xdg.configFile links .config/nvim/ tree
  ghostty.nix                    # xdg.configFile for ghostty config
  packages.nix                   # home.packages (nodejs, bun, go, zig, fonts…)
```

**Key rule (from nixos-best-practices skill):** `useGlobalPkgs = true` is set in `hosts/citadel/default.nix`. Any `nixpkgs.overlays` must be declared there (in the `home-manager` block), not inside `modules/home/*.nix` — they'd be silently ignored.

## Config source files (referenced by nix modules)

- `.config/nvim/` — Neovim Lua config (linked verbatim; plugins managed by nvim itself).
- `.config/waybar/` — Waybar bar config + CSS (not yet in a nix module; manage with `xdg.configFile` if needed).
- `.config/keyd/default.conf` — Source of truth for the keyd mapping; the nix version in `hosts/citadel/default.nix` mirrors it.
- `.config/sunshine/` — Sunshine game streaming config (tracked manually; credentials excluded via `.gitignore`).

## How stow and nix interact

`flake.nix`, `flake.lock`, `hosts/`, and `modules/` are excluded from stow (listed in `.stow-local-ignore`). The `.config/` subtree is still present and used as the source for `xdg.configFile` references inside nix modules. On NixOS the stow workflow is replaced entirely by `nixos-rebuild switch`.
