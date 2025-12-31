# Configuration Management Improvements

## Overview
This document outlines the improvements made to the NixOS configuration to support managing multiple systems more effectively.

## Changes Made

### 1. System Configuration Matrix (`docs/HOSTS.md`)
**Purpose**: Provide clear documentation of all configured systems and their profiles.

**Benefits**:
- Quick reference for which profiles each host imports
- Clear visibility of system differences
- Template for adding new hosts
- Reduces confusion when making changes

**Files**:
- `docs/HOSTS.md` - Complete system matrix with profiles reference

### 2. Form Factor Profile (`modules/profiles/form-factor.nix`)
**Purpose**: Consolidate desktop vs laptop distinctions in a reusable module.

**Benefits**:
- Reduces conditional logic scattered across profiles
- Single source of truth for form factor-specific settings
- Easier to add new form factor types in future

**Current Status**: Created but not yet integrated (requires bladeupdate to use `formFactor` option)

**Future Integration**:
```nix
# In hosts/blade/default.nix
config.formFactor = "laptop";
```

### 3. Hardware Common Profile (`modules/profiles/hardware-common.nix`)
**Purpose**: Standardize hardware configuration across all hosts.

**Benefits**:
- Eliminates duplicate hardware settings
- Ensures consistency in firmware, graphics, Bluetooth, etc.
- Easier to manage hardware-related changes

**Configuration Covered**:
- Firmware enablement
- GPU acceleration
- Bluetooth setup
- CPU frequency scaling
- Standard hardware monitoring tools

**Future Integration**:
```nix
# In hosts/*/default.nix
../../modules/profiles/hardware-common.nix
```

### 4. Enhanced Makefile (`Makefile`)
**Purpose**: Add convenience targets for managing all systems.

**New Commands**:
- `make build-all` - Build all NixOS configurations without switching (useful for CI/validation)
- `make check-all` - Validate all configurations

**Benefits**:
- Catch configuration errors before applying to any system
- Easy batch builds for testing or caching
- Supports multi-system workflows

### 5. Updated Documentation (`docs/HOSTS.md`)
**Purpose**: Clear documentation of configuration structure and procedures.

**Includes**:
- System configuration matrix
- Profile reference guide
- Quick command reference
- Template for adding new hosts
- Host management procedures

## Recommended Next Steps

### Immediate (Low Risk)
1. **Integrate `hardware-common.nix`** into all NixOS hosts
   ```bash
   # Add to each host's default.nix imports
   ../../modules/profiles/hardware-common.nix
   ```

2. **Test new Makefile commands**
   ```bash
   make check-all
   make build-all  # Warning: will take time on first build
   ```

3. **Review HOSTS.md** for accuracy and update as needed

### Short Term (Medium Effort)
4. **Integrate `form-factor.nix`** 
   - Update hosts to use `formFactor` option instead of `laptop` parameter
   - Consolidates configuration logic
   - Reduces conditional branches in profiles

5. **Create host template**
   - Add `hosts/template/` with standard structure
   - Use as starting point for new machines

### Medium Term (Higher Effort)
6. **Add system-specific test targets**
   ```makefile
   test-blackbox:
   	sudo nixos-rebuild test --flake .#blackbox
   test-blade:
   	sudo nixos-rebuild test --flake .#blade
   ```

7. **Create configuration linting** 
   - Add `lint` target to validate Nix syntax
   - Check for common issues (undefined options, etc.)

8. **Add CI/CD support**
   - GitHub Actions workflow for `make check-all` + `make build-all`
   - Prevents broken configs from being committed

## Migration Path for Existing Systems

### For blade (laptop)
No changes required. Current configuration remains fully functional.
- `laptop = true` will continue to work as before
- Optional: Migrate to `formFactor = "laptop"` when ready

### For blackbox (desktop)
No changes required. Current configuration remains fully functional.
- `laptop = false` will continue to work as before
- Optional: Migrate to `formFactor = "desktop"` when ready

## Testing Changes

Before committing configuration changes to a system, always test:

```bash
# Test without applying
sudo nixos-rebuild test --flake .#<hostname>

# Build all to catch issues early
make build-all

# Validate syntax and structure
make check-all
```

## Configuration Validation Checklist

When adding or modifying hosts:

- [ ] Host added to `flake.nix` nixosConfigurations
- [ ] Host added to `Makefile` .PHONY and shortcut target
- [ ] `hosts/<hostname>/default.nix` has correct imports
- [ ] `hosts/<hostname>/hardware-configuration.nix` generated on target machine
- [ ] `make check` passes
- [ ] Home Manager user configuration exists and is imported
- [ ] Documentation updated in `docs/HOSTS.md`
- [ ] Tested with `sudo nixos-rebuild test --flake .#<hostname>`

## Benefits Summary

| Improvement | Benefit | Risk |
|-------------|---------|------|
| HOSTS.md | Clear visibility of all systems | None |
| form-factor.nix | Reduced conditional logic | Low (backward compatible) |
| hardware-common.nix | Standardized hardware setup | Low (consolidates existing config) |
| Makefile targets | Catch errors early | None |
| Documentation | Easier onboarding | None |

All improvements maintain backward compatibility with existing configurations.
