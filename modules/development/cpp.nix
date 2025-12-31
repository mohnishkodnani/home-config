{pkgs, ...}: {
  # C/C++ Development Tools
  #
  # Nix Learning Point:
  # C++ development needs build systems, package managers, and tooling.
  # Each tool serves a specific purpose in the development workflow.

  home.packages = with pkgs; [
    # Build Systems
    cmake # Meta-build system - generates makefiles/ninja files
    ninja # Fast build system (like make, but faster)

    # Package Managers
    conan # C/C++ dependency manager (like npm for C++)
    vcpkg # Microsoft's C++ package manager

    # Documentation & Formatting
    doxygen # Generates documentation from C++ code comments
    cmake-format # Formats CMakeLists.txt files for readability

    # Build Dependencies
    pkg-config-unwrapped # Helper for finding libraries during compilation
  ];
}
