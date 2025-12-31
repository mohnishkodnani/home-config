# Base Profile Configuration
#
# Nix Learning Point - Profile System:
# Profiles allow one codebase to support multiple environments.
# This base profile contains settings shared across ALL environments.
#
# Other profiles (work.nix, personal.nix) import and extend this base.
{
  # State version for Home Manager
  stateVersion = "25.05";

  # Common directories
  nixConfigDirectory = "/Users/mkodnani/.config/nixpkgs";

  # Common tool preferences
  editor = "nvim";
  shell = "fish";
}
