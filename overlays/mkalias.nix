# mkalias Overlay
#
# Nix Learning Point - Overlay Pattern:
# final: prev: { ... }
#   - 'prev' = the package set BEFORE this overlay
#   - 'final' = the package set AFTER all overlays (can reference other overlays)
#   - Return attribute set with packages to add/override
#
# This overlay adds the 'mkalias' tool from an external flake input.
# mkalias creates aliases for macOS GUI apps so they work with Finder.
{inputs}: final: prev: {
  # Use prev.stdenv to get current system info
  # ${...} interpolates the system string (e.g., "aarch64-darwin")
  # This makes it portable across systems
  mkalias = inputs.mkalias.outputs.apps.${prev.stdenv.hostPlatform.system}.default.program;
}
