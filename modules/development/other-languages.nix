{pkgs, ...}: {
  # Other Programming Languages
  #
  # Non-primary languages used less frequently.
  # Grouped together since none require extensive tooling setup.
  # Primary development languages (JVM/Scala, Nix) have their own modules.

  home.packages = with pkgs; [
    # Node.js - JavaScript runtime
    nodejs_24

    # Go - Systems programming language
    go # Go compiler and toolchain (includes gopls LSP server)

    # Elixir - Functional language on Erlang VM
    elixir # Elixir compiler and runtime
    livebook # Interactive notebook for Elixir (like Jupyter)

    # Zig - Modern systems programming language
    zig # Zig compiler
    zls # Zig Language Server
  ];
}
