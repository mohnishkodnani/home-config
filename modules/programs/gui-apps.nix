{pkgs, ...}: {
  # GUI Applications
  #
  # This module installs graphical applications that aren't part of the core
  # terminal environment.

  home.packages = with pkgs; [
    brave # Privacy-focused web browser
    google-chrome # Standard web browser
    spotify # Music streaming client
    vlc # Multi-platform media player
    obsidian # Note-taking and knowledge management
    darktable # Photography workflow and raw developer
    protonvpn-gui # ProtonVPN graphical client
  ];
}
