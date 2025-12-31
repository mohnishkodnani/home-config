# ============================================================================
# FLAKE.NIX - Main Entry Point for Nix Home Manager Configuration
# ============================================================================
#
# WHAT IS THIS FILE?
# ------------------
# This is a Nix "flake" - the modern way to configure reproducible development
# environments and system configurations. Think of it as a package.json or
# Cargo.toml for your entire development environment.
#
# WHY FLAKE-PARTS?
# ----------------
# Instead of writing everything in one file, we use "flake-parts" framework
# to split configuration into logical modules. This makes it easier to:
# - Understand what each piece does
# - Reuse code across different machines
# - Maintain and update specific parts without breaking others
#
# KEY CONCEPTS FOR NIX BEGINNERS:
# --------------------------------
# 1. INPUTS: External dependencies (like npm packages)
#    - Where we get software from (nixpkgs, home-manager, etc.)
#
# 2. OUTPUTS: What this flake produces
#    - Development shells (for different Java versions)
#    - Home configurations (for different machines)
#    - Overlays (custom package modifications)
#
# 3. SYSTEMS: Architectures we support
#    - aarch64-darwin = Apple Silicon Macs (M1, M2, M3)
#    - x86_64-linux = Intel/AMD Linux machines
#
# 4. OVERLAYS: Custom package modifications
#    - Think of them as "monkey patches" for packages
#    - We use them to add VS Code extensions and macOS utilities
#
# ============================================================================
{
  description = "Flake to manage software and home directory settings through nix home manager.";

  # ============================================================================
  # INPUTS - External Dependencies
  # ============================================================================
  # These are like "dependencies" in package.json. Each input is a source of
  # packages or functionality that we need. The "follows" keyword ensures all
  # inputs use the SAME version of nixpkgs to avoid conflicts.

  inputs = {
    # --------------------------------------------------------------------------
    # Core Package Repository
    # --------------------------------------------------------------------------
    # nixpkgs: The main repository of 80,000+ packages
    # "nixpkgs-unstable" gives us the latest versions (updated weekly)
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # --------------------------------------------------------------------------
    # Home Manager - Manages dotfiles and user environment
    # --------------------------------------------------------------------------
    # Home Manager lets us configure our home directory declaratively:
    # - Shell configuration (fish, bash, zsh)
    # - Editor configs (neovim, vscode)
    # - GUI apps (kitty terminal, VS Code)
    # - Development tools (git, ssh, etc.)
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs"; # Use same nixpkgs version

    # --------------------------------------------------------------------------
    # Flake Parts - Modular Configuration Framework
    # --------------------------------------------------------------------------
    # Instead of one giant flake.nix file, flake-parts lets us split config
    # into multiple files (home-configurations.nix, devshells.nix, etc.)
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    # --------------------------------------------------------------------------
    # macOS Utilities
    # --------------------------------------------------------------------------
    # mkalias: Creates proper macOS aliases for GUI apps
    # Without this, GUI apps installed via Nix won't show up in Spotlight/Finder
    mkalias.url = "github:mohnishkodnani/mkalias";
    mkalias.inputs.nixpkgs.follows = "nixpkgs";

    # --------------------------------------------------------------------------
    # Development Tools
    # --------------------------------------------------------------------------
    # nix4vscode: Fetch VS Code extensions from the marketplace
    # Normally VS Code extensions aren't in nixpkgs, this tool downloads them
    nix4vscode.url = "github:nix-community/nix4vscode";
    nix4vscode.inputs.nixpkgs.follows = "nixpkgs";

    # oxalica/nil: Nix language server for IDE autocomplete and errors
    oxalica.url = "github:oxalica/nil";
    oxalica.inputs.nixpkgs.follows = "nixpkgs";
  };

  # ============================================================================
  # OUTPUTS - What This Flake Produces
  # ============================================================================
  # The outputs function defines what this flake provides to the world.
  #
  # SYNTAX EXPLANATION:
  #   inputs @ { flake-parts, ... }:
  #     - inputs: All the inputs defined above
  #     - @: "Bind the whole set to 'inputs' AND destructure it"
  #     - { flake-parts, ... }: Extract 'flake-parts' for immediate use
  #     - ...: "And all the other inputs too"

  outputs = inputs @ {flake-parts, ...}:
  # Instead of manually defining outputs, we use flake-parts framework
  # This gives us a clean structure with perSystem (system-specific) and
  # flake-wide outputs
    flake-parts.lib.mkFlake {inherit inputs;} {
      # ========================================================================
      # System Architectures We Support
      # ========================================================================
      # This flake works on:
      # - aarch64-darwin: Apple Silicon Macs (M1/M2/M3 chips)
      # - x86_64-linux: Intel/AMD Linux machines
      #
      # When you run "nix develop" or "nix build", it automatically picks
      # the right configuration for your system
      systems = ["aarch64-darwin" "x86_64-linux"];

      # ========================================================================
      # Per-System Configuration
      # ========================================================================
      # This section runs ONCE PER SYSTEM (once for aarch64-darwin, once for
      # x86_64-linux). It configures how nixpkgs behaves on each system.
      #
      # WHY perSystem?
      # - Avoids repeating "if system == aarch64-darwin then ..."
      # - Flake-parts automatically creates outputs for each system
      # - Makes it easy to support multiple architectures
      #
      # WHAT IS _module.args.pkgs?
      # - Sets up the "pkgs" variable used throughout all modules
      # - Applies our overlays (custom package modifications)
      # - Configures nixpkgs settings (allow unfree, etc.)
      perSystem = {system, ...}: {
        # Configure the 'pkgs' variable available to all modules
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system; # Pass the current system (aarch64-darwin or x86_64-linux)

          # nixpkgs configuration options
          config = {
            # Allow proprietary software (VS Code, Obsidian, etc.)
            allowUnfree = true;

            # Allow packages that might not officially support this system
            # Sometimes works anyway!
            allowUnsupportedSystem = true;

            # Allow packages marked as "broken"
            # Useful when a package is marked broken but actually works
            allowBroken = true;
          };

          # Apply our custom package overlays
          # Overlays add or modify packages (like adding VS Code extensions)
          overlays = import ./overlays/default.nix {inherit inputs;};
        };
      };

      # ========================================================================
      # Import Modular Configuration Files
      # ========================================================================
      # Instead of defining everything here, we split the config into:
      #
      # 1. home-configurations.nix
      #    - Defines machine-specific configs (work-macbook, personal-linux)
      #    - Manages which modules to load
      #    - Handles profile selection (work vs personal)
      #
      # 2. devshells.nix
      #    - Development environments for different Java versions
      #    - Both personal shells (nixpkgs JDKs) and work shells (company JDKs)
      #
      # 3. overlays.nix
      #    - Package customizations (nix4vscode, mkalias)
      #
      # BEGINNER TIP:
      # Think of imports like "require()" in Node.js or "import" in Python.
      # Each file exports configuration that gets merged into this flake.
      imports = [
        ./flake-parts/home-configurations.nix # Machine configs
        ./flake-parts/devshells.nix # Development shells
        ./flake-parts/overlays.nix # Package overlays
      ];
    };
}
