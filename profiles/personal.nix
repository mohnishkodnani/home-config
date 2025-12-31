# ============================================================================
# PERSONAL PROFILE CONFIGURATION
# ============================================================================
#
# WHAT IS THIS FILE?
# ------------------
# This is a PROFILE - a configuration template that defines your personal
# settings for home-manager. Think of it as a "config file for your config".
#
# WHY PROFILES?
# -------------
# Profiles allow you to:
# - Separate personal and work settings
# - Define user information in one place
# - Choose which JDK source to use (nixpkgs vs company-certified)
# - Customize which tools and versions are enabled
#
# HOW TO USE:
# -----------
# 1. Copy this file or edit it directly
# 2. Replace placeholder values with your real information
# 3. Enable/disable JDK versions as needed
# 4. Run: home-manager switch --flake .#personal-linux
#
# FOR PUBLIC REPOS:
# -----------------
# This file contains PLACEHOLDER values. Do NOT commit your real:
# - Email address
# - Full name
# - SSH key paths (if they're non-standard)
#
# Keep your real personal.nix in a private repo or outside git.
#
# ============================================================================
{
  # ==========================================================================
  # Base Configuration
  # ==========================================================================
  # Import shared settings like stateVersion
  _base = import ./base.nix;

  # ==========================================================================
  # Profile Identifier
  # ==========================================================================
  # Used by modules to determine which configuration to apply
  profile = "personal";

  # ==========================================================================
  # User Information
  # ==========================================================================
  # REPLACE THESE PLACEHOLDERS WITH YOUR REAL INFORMATION
  #
  # NIX LEARNING: These values are used by git module, ssh module, etc.
  # They're accessed in other modules as: profile.user.name, profile.user.email
  user = {
    name = "Your Full Name"; # Your real name for git commits
    email = "you@example.com"; # Your personal email
    username = "yourusername"; # Your Unix username
    fullName = "Your Full Name"; # Same as name (for compatibility)
  };

  # ==========================================================================
  # Git Configuration
  # ==========================================================================
  # Settings for git module (programs/git.nix)
  git = {
    # GPG signing for commits (set to true if you use GPG)
    signing = false;

    # SSH key paths for different git hosts
    # NIX LEARNING: These are referenced in ~/.ssh/config
    sshKeys = {
      github = "~/.ssh/id_github"; # Your GitHub SSH key
      ed25519 = "~/.ssh/id_ed25519"; # General-purpose key
    };

    # Git host configurations
    # For personal use, usually just GitHub/GitLab
    hosts = {
      # Example:
      # "github.com" = {
      #   user = "git";
      #   identityFile = "~/.ssh/id_github";
      # };
    };
  };

  # ==========================================================================
  # JDK Configuration
  # ==========================================================================
  # Controls which Java Development Kits are available
  #
  # NIX LEARNING: This config is used by:
  # - modules/jdk-manager.nix (to get the right JDK)
  # - flake-parts/devshells.nix (to create dev environments)
  jdk = {
    # JDK Source
    # - "nixpkgs": Use standard JDKs from nixpkgs (public)
    # - "company": Use company-certified JDKs (requires private repo)
    source = "nixpkgs";

    # Which JDK versions to enable
    # NIX LEARNING: Set enable = true for versions you need
    # This allows you to switch between JDKs with: nix develop .#jdk17
    versions = {
      jdk8.enable = false; # Legacy Java 8 (usually not needed for personal)
      jdk11.enable = false; # Java 11 LTS
      jdk17.enable = true; # Java 17 LTS (recommended for most projects)
      jdk21.enable = true; # Java 21 LTS (latest, use for new projects)
    };

    # Default JDK version
    # NIX LEARNING: This is used when no specific version is requested
    # Available values: "jdk8", "jdk11", "jdk17", "jdk21"
    default = "jdk21";
  };

  # ==========================================================================
  # Tool Preferences
  # ==========================================================================
  # Optional settings to customize which tools are installed
  #
  # NOTE: These are example fields. The actual modules may not use these yet.
  # Extend this as your configuration grows.
  tools = {
    enableWorkTools = true; # Maven, Gradle, etc. for side projects
    enableIDEs = false; # Use lighter editors (neovim, vs code)
  };
}
