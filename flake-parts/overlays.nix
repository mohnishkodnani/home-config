# ============================================================================
# OVERLAYS.NIX - Package Overlays
# ============================================================================
#
# WHAT IS THIS FILE?
# ------------------
# This file exports nixpkgs "overlays" - modifications or additions to the
# standard package set. Think of overlays as "monkey patches" for packages.
#
# WHY USE OVERLAYS?
# -----------------
# Overlays let us:
# - Add new packages not in nixpkgs (like VS Code extensions)
# - Modify existing packages (like adding certificates to curl)
# - Make packages available everywhere in our config
#
# CURRENT OVERLAYS:
# -----------------
# 1. nix4vscode: Fetches VS Code extensions from the marketplace
#    - VS Code extensions aren't normally in nixpkgs
#    - This overlay adds them so we can install them declaratively
#
# 2. mkalias: Creates macOS aliases for GUI apps
#    - Makes Nix-installed apps appear in Spotlight and Finder
#    - Without this, GUI apps are invisible to macOS
#
# KEY CONCEPTS FOR NIX BEGINNERS:
# --------------------------------
# 1. OVERLAY: A function that modifies the package set
#    - Takes two arguments: final (modified pkgs), prev (original pkgs)
#    - Returns an attribute set of new/modified packages
#    - Example: final: prev: { myPkg = ...; }
#
# 2. composeManyExtensions: Combines multiple overlays into one
#    - Takes a list of overlays
#    - Applies them in order (later overlays can see earlier changes)
#    - Returns a single combined overlay
#
# 3. flake.overlays vs perSystem:
#    - Overlays are NOT system-specific (work on all platforms)
#    - So we use flake.overlays, not perSystem
#
# ============================================================================
# FUNCTION SIGNATURE:
# { inputs, ... }:
#   - inputs: Flake inputs (needed for nix4vscode and mkalias)
#   - ...: Other arguments we don't need
{inputs, ...}: {
  # ==========================================================================
  # Flake-Wide Overlays
  # ==========================================================================
  # Overlays are defined at the flake level (not per-system) because they
  # work across all platforms. The same VS Code extensions work on macOS
  # and Linux, for example.
  flake.overlays = {
    # ------------------------------------------------------------------------
    # Default Overlay
    # ------------------------------------------------------------------------
    # Combines all our individual overlays into one.
    #
    # WHAT IS composeManyExtensions?
    # It's a nixpkgs function that merges multiple overlays:
    #   composeManyExtensions [ overlay1 overlay2 overlay3 ]
    #   → single combined overlay
    #
    # WHY COMBINE?
    # - Easier to manage (one overlay to apply instead of many)
    # - Order matters (later overlays can reference earlier ones)
    # - More efficient (single pass through package set)
    default = inputs.nixpkgs.lib.composeManyExtensions (
      # Import the list of overlays from overlays/default.nix
      # That file returns: [ nix4vscodeOverlay mkaliasOverlay ]
      import ../overlays/default.nix {inherit inputs;}
    );
  };
}
