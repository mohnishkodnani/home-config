# ============================================================================
# DEVSHELLS.NIX - Development Environment Shells
# ============================================================================
#
# WHAT IS THIS FILE?
# ------------------
# This file defines "development shells" - temporary environments with specific
# tools and configurations. Think of them like Python virtualenvs or Node.js
# containers, but for ANY language/tool.
#
# WHY DEVELOPMENT SHELLS?
# -----------------------
# - Per-project isolation: Different projects need different Java versions
# - Reproducibility: Same environment on macOS, Linux, and other machines
# - No global installs: Don't pollute your system with conflicting versions
# - Easy switching: `nix develop .#jdk17` vs `nix develop .#jdk21`
#
# DEVELOPMENT SHELLS:
# -------------------
# This file provides personal development shells with standard nixpkgs JDKs.
# These shells are fully functional in the public repo.
#
# AVAILABLE SHELLS:
# - jdk17: Java 17 + Scala development
# - jdk21: Java 21 (latest LTS)
# - scala: Full Scala environment with all tools
# - nix: Nix development with formatters
#
# USAGE EXAMPLES:
# ---------------
# nix develop .#jdk17        # Java 17 + Scala + Maven
# nix develop .#jdk21        # Java 21 + Gradle
# nix develop .#scala        # Comprehensive Scala environment
# nix develop .#nix          # Nix development tools
#
# FOR WORK SHELLS (company-certified JDKs):
# -----------------------------------------
# See work-repo-template/flake-parts/work-devshells.nix for company-specific
# shells that use custom JDKs with enterprise certificates.
#
# KEY CONCEPTS FOR NIX BEGINNERS:
# --------------------------------
# 1. pkgs.mkShell: Creates a development environment
#    - packages: List of tools to install
#    - shellHook: Commands to run when entering the shell
#
# 2. with pkgs; [ ... ]: Syntax sugar for accessing packages
#    - Instead of: [ pkgs.maven pkgs.gradle ]
#    - Write: with pkgs; [ maven gradle ]
#
# 3. perSystem: Runs once per system architecture
#    - Automatically handles aarch64-darwin (M1/M2/M3 Macs)
#    - Automatically handles x86_64-linux (Intel/AMD Linux)
#
# 4. getJdk function: Abstraction that picks the right JDK
#    - getJdk "17" → nixpkgs JDK 17
#
# ============================================================================
# FUNCTION SIGNATURE:
# { inputs, ... }:
#   - inputs: All flake inputs (currently unused, but kept for consistency)
#   - ...: Any other arguments (we don't need them here)
{inputs, ...}: {
  # ==========================================================================
  # Per-System Configuration
  # ==========================================================================
  # perSystem runs ONCE for each system in systems = [ "aarch64-darwin" "x86_64-linux" ]
  # This ensures dev shells work on both macOS and Linux without duplication.
  #
  # PARAMETERS:
  #   pkgs: Package set for this specific system (auto-provided by flake-parts)
  #   system: Current system string like "aarch64-darwin" (auto-provided)
  #   ...: Other flake-parts stuff we don't need
  perSystem = {
    pkgs,
    system,
    ...
  }: let
    # Import helper function from nixpkgs library
    # removePrefix: Removes a string prefix
    # Example: removePrefix "jdk" "jdk17" → "17"
    inherit (pkgs.lib) removePrefix;

    # ------------------------------------------------------------------------
    # Helper Function: Extract Version Number from JDK String
    # ------------------------------------------------------------------------
    # Converts "jdk17" → "17", "jdk21" → "21", etc.
    # Used to get the version from profile.jdk.default (which is like "jdk17")
    getVersionNum = jdkStr: removePrefix "jdk" jdkStr;

    # ==========================================================================
    # PERSONAL PROFILE SETUP
    # ==========================================================================
    # These shells use STANDARD nixpkgs JDKs (no company certificates)
    # Good for: Personal projects, open source work, learning

    # Load the personal profile
    # Contains settings like jdk.default, jdk.source = "nixpkgs"
    personalProfile = import ../profiles/personal.nix;

    # Create a JDK manager for personal profile
    # The manager provides a getJdk function that knows how to fetch
    # the right JDK based on the profile settings
    personalJdkManager = import ../modules/jdk-manager.nix {
      inherit pkgs;
      profile = personalProfile;
      companyJdks = null; # No company JDKs for personal profile
      lib = pkgs.lib; # Pass library functions
    };

    # Extract the getJdk function for easy access
    # Usage: personalGetJdk "17" → nixpkgs JDK 17 package
    personalGetJdk = personalJdkManager.lib.getJdk;
  in {
    # ==========================================================================
    # Development Shells
    # ==========================================================================
    # Each shell is a complete development environment with specific tools.
    # When you run `nix develop .#shellname`, you get a new shell with:
    # - All packages in $PATH
    # - Environment variables set by shellHook
    # - Isolated from your system environment
    devShells = {
      # ========================================================================
      # PERSONAL SHELLS (Standard nixpkgs JDKs)
      # ========================================================================

      # ------------------------------------------------------------------------
      # JDK 17 Shell
      # ------------------------------------------------------------------------
      # Java 17 + Scala development environment
      # Most common for modern personal projects
      #
      # USAGE: nix develop .#jdk17
      jdk17 = pkgs.mkShell {
        name = "jdk17-dev"; # Shell name (shown in prompt)

        # Packages to install in this shell
        # "with pkgs;" lets us write "maven" instead of "pkgs.maven"
        packages = with pkgs; [
          (personalGetJdk "17") # Java 17 from nixpkgs
          maven # Build tool for Java
          sbt-extras # Scala Build Tool
          metals # Scala language server for IDEs
          coursier # Scala dependency manager
          scala-cli # Modern Scala scripting tool
        ];

        # Commands to run when entering the shell
        # These set up environment variables and print welcome messages
        shellHook = ''
          export JAVA_HOME=${personalGetJdk "17"}
          export MAVEN_OPTS="-Xmx2g"    # Give Maven 2GB of RAM
          export SBT_OPTS="-Xmx2g"      # Give SBT 2GB of RAM
          echo "☕ Java 17 + Scala environment (nixpkgs JDKs)"
          echo "   JAVA_HOME: $JAVA_HOME"
        '';
      };

      # ------------------------------------------------------------------------
      # JDK 21 Shell
      # ------------------------------------------------------------------------
      # Java 21 environment (latest LTS as of 2024)
      #
      # USAGE: nix develop .#jdk21
      jdk21 = pkgs.mkShell {
        name = "jdk21-dev";
        packages = with pkgs; [
          (personalGetJdk "21") # Java 21 from nixpkgs
          maven # Build tool
          gradle # Alternative build tool
        ];
        shellHook = ''
          export JAVA_HOME=${personalGetJdk "21"}
          export MAVEN_OPTS="-Xmx2g"
          echo "☕ Java 21 environment (nixpkgs JDKs)"
          echo "   JAVA_HOME: $JAVA_HOME"
        '';
      };

      # ------------------------------------------------------------------------
      # Nix Development Shell
      # ------------------------------------------------------------------------
      # For working on Nix code itself (no Java)
      # Includes formatters and build monitoring tools
      #
      # USAGE: nix develop .#nix
      nix = pkgs.mkShell {
        name = "nix-dev";
        packages = with pkgs; [
          nixpkgs-fmt # Official Nix formatter
          alejandra # Alternative Nix formatter (prettier output)
          nix-output-monitor # Pretty build output (use `nom build` instead of `nix build`)
        ];
        shellHook = ''
          echo "❄️  Nix development environment"
          echo "   Formatters: nixpkgs-fmt, alejandra"
          echo "   Build monitor: nom"
        '';
      };

      # ------------------------------------------------------------------------
      # Scala Development Shell
      # ------------------------------------------------------------------------
      # Comprehensive Scala environment with all the bells and whistles
      # Uses the default JDK from personal profile
      #
      # USAGE: nix develop .#scala
      scala = pkgs.mkShell {
        name = "scala-dev";
        packages = with pkgs; [
          # Get JDK from profile default (e.g., jdk17)
          # getVersionNum converts "jdk17" → "17"
          (personalGetJdk (getVersionNum personalProfile.jdk.default))
          sbt-extras # Scala Build Tool
          metals # Scala language server (for VS Code, IntelliJ)
          coursier # Dependency manager
          scala-cli # Modern Scala scripting
          ammonite # Scala REPL with extra features
        ];
        shellHook = ''
          export JAVA_HOME=${personalGetJdk (getVersionNum personalProfile.jdk.default)}
          export SBT_OPTS="-Xmx2g"
          echo "🔺 Scala environment (nixpkgs JDKs, ${personalProfile.jdk.default})"
          echo "   JAVA_HOME: $JAVA_HOME"
          echo "   Use 'nix develop .#jdk17' for specific JDK versions"
        '';
      };
    };
  };
}
