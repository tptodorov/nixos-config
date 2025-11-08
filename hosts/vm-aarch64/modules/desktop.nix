{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Import blackbox desktop configuration and override for VM
  imports = [
    ../../blackbox/modules/desktop.nix
  ];

  # VM-specific overrides
  # Disable audio services (VM doesn't need them)
  services.pipewire.enable = lib.mkForce false;
  services.pulseaudio.enable = lib.mkForce false;
  security.rtkit.enable = lib.mkForce false;

  # Lots of stuff that uses aarch64 that claims doesn't work, but actually works.
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = true;

  # VM-specific additions
  virtualisation.vmware.guest = {
    enable = true;
    headless = false;
  };

  # Enable Sway window manager for VM
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      swaylock
      swayidle
      swaybg
      wl-clipboard
      grim
      slurp
      wofi
      foot
    ];
  };

  # Add VM-specific packages to the blackbox package list
  environment.systemPackages = with pkgs; [
    # VM-specific tools
    phoronix-test-suite
    # Clipboard tools for VMware guest
    wl-clipboard
    xclip
  ];

  # VM-specific graphics configuration (override blackbox settings)
  # NOTE: ARM64 VMs in VMware Fusion have limited 3D acceleration support
  # The vmwgfx driver loads but falls back to software rendering (llvmpipe)
  # This is a VMware limitation, not a NixOS issue
  hardware.graphics = {
    enable = lib.mkForce true;
    # Note: enable32Bit is only supported on x86_64, not aarch64
    extraPackages = with pkgs; [
      # Mesa for software rendering (llvmpipe)
      mesa
      libGL
      libGLU
      # Additional OpenGL libraries
      freeglut
      glew
      glfw
      # VMware specific
      open-vm-tools
      # Debug tools
      mesa-demos
      vulkan-tools
    ];
  };

  # VM-specific environment variables (extend blackbox variables)
  environment.sessionVariables = {
    # Graphics configuration for ARM64 VM
    LIBGL_ALWAYS_INDIRECT = "0";
    LIBGL_ALWAYS_SOFTWARE = "0";
    MESA_GL_VERSION_OVERRIDE = "4.5";
    MESA_GLSL_VERSION_OVERRIDE = "450";
    # Use llvmpipe (software) renderer - ARM64 VMs don't have HW acceleration
    GALLIUM_DRIVER = "llvmpipe";
    # Zed editor - allow emulated GPU in VMs
    ZED_ALLOW_EMULATED_GPU = "1";
    # Display scaling for VM (2x scaling)
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_SCALE_FACTOR = "2";
    # General GPU debugging (can be disabled for better performance)
    # MESA_DEBUG = "1";
    # LIBGL_DEBUG = "verbose";
  };
}
