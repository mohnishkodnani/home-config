{pkgs, ...}: {
  # Rust Development Tools
  #
  # Nix Learning Point:
  # This is a simple module - just takes pkgs and returns packages.
  # Notice how we can organize related tools together for clarity.

  home.packages = with pkgs; [
    # Core Rust toolchain
    cargo # Rust package manager and build tool (like npm/maven)
    rustc # Rust compiler (transforms .rs files to binaries)
    rust-analyzer # Rust Language Server - provides IDE features
  ];
}
