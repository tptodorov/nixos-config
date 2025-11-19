# Connectivity info for Linux VM
NIXADDR ?= unset
NIXPORT ?= 22
NIXUSER ?= todor

# Get the path to this Makefile and directory
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# The name of the nixosConfiguration in the flake
# Available NixOS hosts: blackbox, pero, vm-aarch64
NIXNAME ?= vm

# The name of the homeConfiguration for standalone Home Manager
# Available: todor (x86_64), todor-aarch64 (ARM64)
HMNAME ?= todor

# SSH options that are used. These aren't meant to be overridden but are
# reused a lot so we just store them up here.
SSH_OPTIONS=-o PubkeyAuthentication=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o MACs=hmac-sha2-256-etm@openssh.com

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
	@echo "NixOS System Configurations (requires NixOS):"
	@echo "  make switch NIXNAME=<host>    - Apply NixOS system configuration"
	@echo "  make test NIXNAME=<host>      - Test NixOS configuration (no switch)"
	@echo "  make blackbox                 - Apply blackbox configuration"
	@echo "  make pero                     - Apply pero configuration"
	@echo "  make vm                       - Apply vm-aarch64 configuration"
	@echo ""
	@echo "Standalone Home Manager (Arch, Ubuntu, etc.):"
	@echo "  make home-switch              - Apply Home Manager (x86_64)"
	@echo "  make home-switch-backup       - Apply with backup (x86_64)"
	@echo "  make home                     - Shortcut for home-switch"
	@echo "  make home-aarch64             - Apply Home Manager (ARM64)"
	@echo "  make home-switch HMNAME=<cfg> - Apply specific configuration"
	@echo ""
	@echo "Available Configurations:"
	@echo "  NixOS hosts:     blackbox, pero, vm-aarch64"
	@echo "  Home Manager:    todor (x86_64), todor-aarch64 (ARM64)"
	@echo ""
	@echo "VM Management:"
	@echo "  make vm/bootstrap0            - Initial VM bootstrap"
	@echo "  make vm/bootstrap             - Finalize VM setup"
	@echo "  make vm/copy                  - Copy config to VM"
	@echo "  make vm/switch                - Switch VM configuration"
	@echo "  make vm/login                 - SSH into VM"
	@echo ""
	@echo "Secrets Management:"
	@echo "  make secrets/backup           - Backup SSH/GPG keys"
	@echo "  make secrets/restore          - Restore from backup"
	@echo ""
	@echo "Flake Management:"
	@echo "  make check                    - Validate flake configuration"
	@echo "  make update                   - Update flake inputs"
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
.PHONY: blackbox pero vm home home-aarch64
blackbox:
	$(MAKE) switch NIXNAME=blackbox

pero:
	$(MAKE) switch NIXNAME=pero

vm:
	$(MAKE) switch NIXNAME=vm-aarch64

home:
	$(MAKE) home-switch HMNAME=todor

home-aarch64:
	$(MAKE) home-switch HMNAME=todor-aarch64

# Flake management
.PHONY: check flake-check update flake-update
check flake-check:
	nix flake check

update flake-update:
	nix flake update

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

# bootstrap a brand new VM. The VM should have NixOS ISO on the CD drive
# and just set the password of the root user to "root". This will install
# NixOS. After installing NixOS, you must reboot and set the root password
# for the next step.
#
# NOTE(mitchellh): I'm sure there is a way to do this and bootstrap all
# in one step but when I tried to merge them I got errors. One day.
vm/bootstrap0:
	ssh $(SSH_OPTIONS) -p$(NIXPORT) root@$(NIXADDR) " \
		parted /dev/sda -- mklabel gpt; \
		parted /dev/sda -- mkpart primary 512MB -8GB; \
		parted /dev/sda -- mkpart primary linux-swap -8GB 100\%; \
		parted /dev/sda -- mkpart ESP fat32 1MB 512MB; \
		parted /dev/sda -- set 3 esp on; \
		sleep 1; \
		mkfs.ext4 -L nixos /dev/sda1; \
		mkswap -L swap /dev/sda2; \
		mkfs.fat -F 32 -n boot /dev/sda3; \
		sleep 1; \
		mount /dev/disk/by-label/nixos /mnt; \
		mkdir -p /mnt/boot; \
		mount /dev/disk/by-label/boot /mnt/boot; \
		nixos-generate-config --root /mnt; \
		sed --in-place '/system\.stateVersion = .*/a \
			nix.package = pkgs.nixVersions.latest;\n \
			nix.extraOptions = \"experimental-features = nix-command flakes\";\n \
			nix.settings.substituters = [\"https://mitchellh-nixos-config.cachix.org\"];\n \
			nix.settings.trusted-public-keys = [\"mitchellh-nixos-config.cachix.org-1:bjEbXJyLrL1HZZHBbO4QALnI5faYZppzkU4D2s0G8RQ=\"];\n \
  			services.openssh.enable = true;\n \
			services.openssh.settings.PasswordAuthentication = true;\n \
			services.openssh.settings.PermitRootLogin = \"yes\";\n \
			users.users.root.initialPassword = \"root\";\n \
		' /mnt/etc/nixos/configuration.nix; \
		nixos-install --no-root-passwd && reboot; \
	"

# after bootstrap0, run this to finalize. After this, do everything else
# in the VM unless secrets change.
vm/bootstrap:
	NIXUSER=root $(MAKE) vm/copy
	NIXUSER=root $(MAKE) vm/switch
	# $(MAKE) vm/secrets
	# # to be able to ssh into the VM
	# NIXUSER=root $(MAKE) vm/secrets

vm/login:
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR)

# copy our secrets into the VM
vm/secrets:
	# GPG keyring
	# rsync -av -e 'ssh $(SSH_OPTIONS)' \
	# 	--exclude='.#*' \
	# 	--exclude='S.*' \
	# 	--exclude='*.conf' \
	# 	$(HOME)/.gnupg/ $(NIXUSER)@$(NIXADDR):~/.gnupg
	# SSH keys
	rsync -av -e 'ssh $(SSH_OPTIONS)' \
		--exclude='environment' \
		$(HOME)/.ssh/ $(NIXUSER)@$(NIXADDR):~/.ssh

# copy the Nix configurations into the VM.
vm/copy:
	rsync -av -e 'ssh $(SSH_OPTIONS) -p$(NIXPORT)' \
		--exclude='vendor/' \
		--exclude='.git/' \
		--exclude='.git-crypt/' \
		--exclude='.jj/' \
		--exclude='iso/' \
		--rsync-path="sudo rsync" \
		$(MAKEFILE_DIR)/ $(NIXUSER)@$(NIXADDR):/nix-config

# run the nixos-rebuild switch command. This does NOT copy files so you
# have to run vm/copy before.
vm/switch:
	ssh $(SSH_OPTIONS) -p$(NIXPORT) $(NIXUSER)@$(NIXADDR) " \
		sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake \"/nix-config#${NIXNAME}\" \
	"

# Build a WSL installer
.PHONY: wsl
wsl:
	 nix build ".#nixosConfigurations.wsl.config.system.build.installer"
