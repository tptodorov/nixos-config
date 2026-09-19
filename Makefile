# Get the path to this Makefile and directory
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# The name of the nixosConfiguration in the flake
# Available NixOS hosts: blackbox, blade
NIXNAME ?= blade

# The name of the homeConfiguration for standalone Home Manager
# Available: todor (x86_64), todor-aarch64 (ARM64)
HMNAME ?= todor

# We need to do some OS switching below.
UNAME := $(shell uname)
ARCH := $(shell uname -m)

# Default target
.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo "════════════════════════════════════════════════════════════════════════"
	@echo "  Nix Configuration Management"
	@echo "════════════════════════════════════════════════════════════════════════"
	@echo ""
	@echo "System Configurations:"
	@echo "  make switch NIXNAME=<host>    - Apply system configuration"
	@echo "  make test NIXNAME=<host>      - Test configuration (no switch)"
	@echo "  make blackbox                 - Apply blackbox (NixOS desktop)"
	@echo "  make blade                    - Apply blade (NixOS laptop)"
	@echo "  make mac                      - Apply mac (nix-darwin)"
	@echo ""
	@echo "Standalone Home Manager (Arch, Ubuntu, etc.):"
	@echo "  make home-switch              - Apply Home Manager (x86_64)"
	@echo "  make home-switch-backup       - Apply with backup (x86_64)"
	@echo "  make home                     - Shortcut for home-switch"
	@echo "  make home-aarch64             - Apply Home Manager (ARM64)"
	@echo "  make home-switch HMNAME=<cfg> - Apply specific configuration"
	@echo ""
	@echo "Available Configurations:"
	@echo "  NixOS hosts:     blackbox, blade"
	@echo "  nix-darwin:      mac"
	@echo "  Home Manager:    todor (x86_64), todor-aarch64 (ARM64)"
	@echo ""
	@echo "Secrets Management:"
	@echo "  make secrets/backup           - Backup SSH/GPG keys"
	@echo "  make secrets/restore          - Restore from backup"
	@echo ""
	@echo "Flake Management:"
	@echo "  make check                    - Validate flake configuration"
	@echo "  make check-all                - Validate all configurations"
	@echo "  make build-all                - Build all configurations"
	@echo "  make update                   - Update flake inputs"
	@echo "  make hooks/install            - Configure repo-local git hooks"
	@echo ""
	@echo "Other:"
	@echo "  make cache                    - Build and cache configuration"
	@echo "  make wsl                      - Build WSL installer"
	@echo ""
	@echo "════════════════════════════════════════════════════════════════════════"

# NixOS system configuration switch
switch:
ifeq ($(UNAME), Darwin)
	NIXPKGS_ALLOW_UNFREE=1 nix build --impure --extra-experimental-features nix-command --extra-experimental-features flakes ".#darwinConfigurations.${NIXNAME}.system"
	sudo NIXPKGS_ALLOW_UNFREE=1 ./result/sw/bin/darwin-rebuild switch --impure --flake "$$(pwd)#${NIXNAME}"
else
	sudo NIXPKGS_ALLOW_UNFREE=1 NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --impure --flake ".#${NIXNAME}"
endif

# NixOS system configuration test
test:
ifeq ($(UNAME), Darwin)
	NIXPKGS_ALLOW_UNFREE=1 nix build --impure ".#darwinConfigurations.${NIXNAME}.system"
	sudo NIXPKGS_ALLOW_UNFREE=1 ./result/sw/bin/darwin-rebuild test --impure --flake "$$(pwd)#${NIXNAME}"
else
	sudo NIXPKGS_ALLOW_UNFREE=1 NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild test --impure --flake ".#$(NIXNAME)"
endif

# Standalone Home Manager switch (non-NixOS systems like Arch, Ubuntu, etc.)
.PHONY: home-switch
home-switch:
	home-manager switch --flake ".#${HMNAME}"

# Standalone Home Manager switch with backup
.PHONY: home-switch-backup
home-switch-backup:
	home-manager switch --flake ".#${HMNAME}" -b backup

# Quick shortcuts for specific hosts
.PHONY: blackbox blade mac home home-aarch64
blackbox:
	$(MAKE) switch NIXNAME=blackbox

blade:
	$(MAKE) switch NIXNAME=blade

mac:
	$(MAKE) switch NIXNAME=DR94XJ1435-Todor-Peychev-Todorov

home:
	$(MAKE) home-switch HMNAME=todor

home-aarch64:
	$(MAKE) home-switch HMNAME=todor-aarch64

# Flake management
.PHONY: check flake-check update flake-update build-all check-all hooks/install
check flake-check:
	nix flake check

update flake-update:
	nix flake update

hooks/install:
	git config core.hooksPath .githooks

# Build all NixOS configurations without switching (useful for CI/validation)
build-all:
	@echo "Building all NixOS configurations..."
	nix build '.#nixosConfigurations.blackbox.config.system.build.toplevel'
	nix build '.#nixosConfigurations.blade.config.system.build.toplevel'
	@echo "All configurations built successfully"

# Validate all configurations
check-all: check
	@echo "Validating all home configurations..."
	nix flake show --all-systems

# This builds the given NixOS configuration and pushes the results to the
# cache. This does not alter the current running system. This requires
# cachix authentication to be configured out of band.
cache:
	nix build '.#nixosConfigurations.$(NIXNAME).config.system.build.toplevel' --json \
		| jq -r '.[].outputs | to_entries[].value' \
		| cachix push mitchellh-nixos-config

# Backup secrets so that we can transer them to new machines via
# sneakernet or other means.
.PHONY: secrets/backup
secrets/backup:
	tar -czvf $(MAKEFILE_DIR)/backup.tar.gz \
		-C $(HOME) \
		--exclude='.gnupg/.#*' \
		--exclude='.gnupg/S.*' \
		--exclude='.gnupg/*.conf' \
		--exclude='.ssh/environment' \
		.ssh/ \
		.gnupg

.PHONY: secrets/restore
secrets/restore:
	if [ ! -f $(MAKEFILE_DIR)/backup.tar.gz ]; then \
		echo "Error: backup.tar.gz not found in $(MAKEFILE_DIR)"; \
		exit 1; \
	fi
	echo "Restoring SSH keys and GPG keyring from backup..."
	mkdir -p $(HOME)/.ssh $(HOME)/.gnupg
	tar -xzvf $(MAKEFILE_DIR)/backup.tar.gz -C $(HOME)
	chmod 700 $(HOME)/.ssh $(HOME)/.gnupg
	chmod 600 $(HOME)/.ssh/* || true
	chmod 700 $(HOME)/.gnupg/* || true

# Build a WSL installer
.PHONY: wsl
wsl:
	 nix build ".#nixosConfigurations.wsl.config.system.build.installer"
