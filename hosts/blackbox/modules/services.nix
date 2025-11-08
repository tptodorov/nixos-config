{ config, pkgs, lib, ... }:
{
  # System services configuration
  security.rtkit.enable = true;

  services = {
    # Audio services
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Printing
    printing.enable = true;

    # RDP (Remote Desktop Protocol)
    xrdp = {
      enable = true;
      defaultWindowManager = "${pkgs.writeScript "startwm.sh" ''
        #!/bin/sh
        . /etc/profile
        export XDG_SESSION_TYPE=x11
        export GDK_BACKEND=x11
        exec ${pkgs.dbus}/bin/dbus-launch --exit-with-session ${pkgs.gnome-session}/bin/gnome-session
      ''}";
      openFirewall = true;
    };
  };

  # System settings
  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_US.UTF-8";

  # Nix configuration
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [
    "todor"
    "root"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Custom xrdp xorg.conf for higher resolutions
  environment.etc."xrdp/xorg.conf".text = ''
    Section "ServerLayout"
        Identifier "X11 Server"
        Screen "Screen (xrdpdev)"
        InputDevice "xrdpMouse" "CorePointer"
        InputDevice "xrdpKeyboard" "CoreKeyboard"
    EndSection

    Section "ServerFlags"
        Option "DefaultServerLayout" "X11 Server"
        Option "DontVTSwitch" "on"
        Option "AutoAddDevices" "off"
        Option "AutoAddGPU" "off"
    EndSection

    Section "Module"
        Load "dbe"
        Load "ddc"
        Load "extmod"
        Load "glx"
        Load "int10"
        Load "record"
        Load "vbe"
        Load "xorgxrdp"
        Load "fb"
    EndSection

    Section "InputDevice"
        Identifier "xrdpKeyboard"
        Driver "xrdpkeyb"
    EndSection

    Section "InputDevice"
        Identifier "xrdpMouse"
        Driver "xrdpmouse"
    EndSection

    Section "Monitor"
        Identifier "Monitor"
        Option "DPMS"
        HorizSync 30-200
        VertRefresh 50-120
        # High resolution mode lines for 4K and ultrawide displays
        ModeLine "3840x2160" 533.25 3840 4016 4104 4400 2160 2168 2178 2222 +hsync +vsync
        ModeLine "3440x1440" 419.50 3440 3696 4064 4688 1440 1441 1444 1490 -hsync +vsync
        ModeLine "2560x1440" 241.50 2560 2608 2640 2720 1440 1443 1448 1481 +hsync -vsync
        ModeLine "2560x1600" 348.50 2560 2760 3032 3504 1600 1603 1609 1658 -hsync +vsync
        ModeLine "1920x1200" 193.25 1920 2056 2256 2592 1200 1203 1209 1245 -hsync +vsync
        ModeLine "1920x1080" 173.00 1920 2048 2248 2576 1080 1083 1088 1120 -hsync +vsync
        ModeLine "1680x1050" 146.25 1680 1784 1960 2240 1050 1053 1059 1089 -hsync +vsync
        ModeLine "1600x900" 119.00 1600 1696 1864 2128 900 901 904 932 -hsync +vsync
        ModeLine "1440x900" 106.50 1440 1520 1672 1904 900 903 909 934 -hsync +vsync
        ModeLine "1368x768" 72.25 1368 1416 1448 1528 768 771 781 790 +hsync -vsync
        ModeLine "1280x1024" 135.00 1280 1296 1440 1688 1024 1025 1028 1066 +hsync +vsync
        ModeLine "1280x720" 74.25 1280 1390 1430 1650 720 725 730 750 +hsync +vsync
        ModeLine "1024x768" 78.75 1024 1040 1136 1312 768 769 772 800 +hsync +vsync
        ModeLine "800x600" 40.00 800 840 968 1056 600 601 605 628 +hsync +vsync
        ModeLine "640x480" 25.18 640 656 752 800 480 490 492 525 -hsync -vsync
    EndSection

    Section "Device"
        Identifier "Video Card (xrdpdev)"
        Driver "xrdpdev"
        Option "DRMDevice" "/dev/dri/renderD128"
        Option "DRI3" "1"
        Option "DRMAllowList" "amdgpu i915 msm radeon"
    EndSection

    Section "Screen"
        Identifier "Screen (xrdpdev)"
        Device "Video Card (xrdpdev)"
        Monitor "Monitor"
        DefaultDepth 24
        SubSection "Display"
            Depth 24
            Modes "3840x2160" "3440x1440" "2560x1600" "2560x1440" "1920x1200" "1920x1080" "1680x1050" "1600x900" "1440x900" "1368x768" "1280x1024" "1280x720" "1024x768" "800x600" "640x480"
        EndSubSection
    EndSection
  '';
}