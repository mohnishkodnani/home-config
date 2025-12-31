# User Configuration Helper
#
# Nix Learning Point - Helper Functions:
# This module provides reusable functions to apply user profile settings
# to various modules (git, ssh, etc.)
#
# Usage: import this in modules that need user info
{profile}: {
  # Extract user info from profile
  user = profile.user;

  # Git configuration from profile
  gitConfig = {
    userName = profile.user.name;
    userEmail = profile.user.email;
    signing = profile.git.signing or false;
    signingKey = profile.git.signingKey or "";
  };

  # SSH configuration from profile
  sshConfig = profile.git.sshKeys or {};

  # SSH hosts from profile
  sshHosts = profile.git.hosts or {};
}
