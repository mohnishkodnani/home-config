# Overlays Index
#
# Nix Learning Point:
# Overlays modify the nixpkgs package set. They let you:
# - Override package definitions (change build options)
# - Add new packages not in nixpkgs
# - Fix broken packages
#
# This file exports a list of all overlays to apply.
# Order matters - later overlays can reference changes from earlier ones.
#
# How to add more overlays:
# 1. Create a new .nix file in this directory (e.g., ./my-overlay.nix)
# 2. Add it to the list below: (import ./my-overlay.nix)
# 3. If it needs inputs, pass them: (import ./my-overlay.nix {inherit inputs;})
#
# Example overlay file structure:
#   final: prev: {
#     myPackage = prev.myPackage.override { enableFeature = true; };
#   }
{inputs}: [
  # External overlays from flake inputs
  inputs.nix4vscode.overlays.default

  # Our custom overlays
  (import ./mkalias.nix {inherit inputs;})

  # Add more overlays here as needed
  # (import ./my-overlay.nix)
]
