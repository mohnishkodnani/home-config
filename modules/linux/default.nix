{pkgs, ...}: {
  # Linux System Specifics
  #
  # This module contains settings and packages that are only relevant
  # when running on Linux (Bluetooth, gestures, etc.).

  home.packages = with pkgs; [
    # Bluetooth management
    bluez
    blueman
    bluez-tools

    # Gestures
    touchegg

    # System utilities
    wine # Run Windows applications
    hfsprogs # Support for Apple HFS+ filesystems
    xclip # Command-line interface to the X11 clipboard
  ];

  # Services or extra configuration can be added here
  # services.touchegg.enable = true;
}
