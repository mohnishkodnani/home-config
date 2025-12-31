{pkgs, ...}: {
  # General Development Tools
  #
  # Cross-language development tools that don't belong to a specific language.
  # Examples: debuggers, profilers, build tools that work across languages.

  home.packages = with pkgs; [
    # Debugging
    lldb # LLVM debugger - works with Rust, C, C++, and other LLVM-based languages
  ];
}
