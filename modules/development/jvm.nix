{pkgs, ...}: {
  # JVM Development Tools
  #
  # This module provides packages for Java/Scala/JVM development.
  # Nix Concept: We return an attribute set with a 'home.packages' key
  # that Home Manager understands and will merge with other modules.

  home.packages = with pkgs; [
    # 'with pkgs;' brings all packages from pkgs into scope
    # so we can write 'maven' instead of 'pkgs.maven'
    # Scala Tools
    ammonite # Interactive Scala REPL - try things quickly
    sbt-extras # Enhanced sbt launcher with better defaults
    coursier # Dependency resolver for Scala/Java
    scala-cli # Modern Scala scripting and REPL
    metals # Scala Language Server for IDE integration

    # Build Tools
    maven # Java build tool (XML-based)
    gradle # Modern build tool for JVM (Groovy/Kotlin DSL)

    # Java Language Support
    java-language-server # LSP server for Java (older)
    jdt-language-server # Eclipse JDT Language Server (better)
    visualvm # Profiling and monitoring tool
  ];
}
