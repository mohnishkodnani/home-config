# ============================================================================
# PACKAGES.NIX - Package Installation Module
# ============================================================================
#
# WHAT IS THIS FILE?
# ------------------
# This Home Manager module defines which packages (programs, tools, utilities)
# get installed in your home environment. When you activate your home-manager
# configuration, all these packages become available in your $PATH.
#
# WHERE DO PACKAGES GET INSTALLED?
# ---------------------------------
# Packages are installed in your home directory profile:
# - Binaries: ~/.nix-profile/bin/
# - Libraries: ~/.nix-profile/lib/
# - Man pages: ~/.nix-profile/share/man/
#
# These directories are automatically added to your $PATH and $MANPATH.
#
# HOW TO ADD A NEW PACKAGE:
# --------------------------
# 1. Search for it: https://search.nixos.org/packages
# 2. Add to the appropriate list (defaultPkgs, gitPkgs, etc.)
# 3. Rebuild: home-manager switch --flake .#work-macbook
#
# HOW TO REMOVE A PACKAGE:
# -------------------------
# 1. Remove it from the list
# 2. Rebuild: home-manager switch --flake .#work-macbook
# 3. Old package is automatically removed (Nix is declarative!)
#
# KEY CONCEPTS FOR NIX BEGINNERS:
# --------------------------------
# 1. DECLARATIVE PACKAGE MANAGEMENT:
#    - You declare WHAT you want, not HOW to get it
#    - No "apt install" or "brew install" - just list packages here
#    - Nix figures out how to build/install them
#
# 2. with pkgs; [ ... ]:
#    - Syntactic sugar for accessing packages
#    - Instead of: [ pkgs.bat pkgs.eza pkgs.fzf ]
#    - Write: with pkgs; [ bat eza fzf ]
#
# 3. ++ OPERATOR:
#    - List concatenation
#    - defaultPkgs ++ gitPkgs → combines both lists
#
# 4. PROGRAMS VS HOME.PACKAGES:
#    - programs.X: Enables a program AND generates config files
#    - home.packages: Just installs the program (no config)
#
# ============================================================================
# FUNCTION SIGNATURE:
# { config, pkgs, lib, ... }:
#   - config: Home Manager configuration (for reading other settings)
#   - pkgs: The nixpkgs package set (where packages come from)
#   - lib: Nixpkgs library functions (helpers for common tasks)
#   - ...: Other arguments (company-specific tools passed via _module.args)
{
  config,
  pkgs,
  lib,
  ...
}: let
  # ==========================================================================
  # Default Packages - Core Tools Everyone Needs
  # ==========================================================================
  # These are installed for ALL configurations (work and personal).
  # Organized by category for easier maintenance.
  defaultPkgs = with pkgs; [
    # ------------------------------------------------------------------------
    # Modern Replacements for Classic Unix Tools
    # ------------------------------------------------------------------------
    # These are faster, prettier, and more user-friendly versions of
    # traditional Unix commands
    bat # Better cat with syntax highlighting
    eza # Better ls with colors and git integration
    fzf # Fuzzy finder (Ctrl+R for command history!)
    ripgrep # Better grep (MUCH faster)
    bottom # Better top (system monitor)
    fd # Better find (faster file search)

    # ------------------------------------------------------------------------
    # Terminal & Shell Tools
    # ------------------------------------------------------------------------
    tmux # Terminal multiplexer (multiple panes/windows)
    fastfetch # Display system info (much faster than neofetch)
    nushell # Modern shell with structured data

    # ------------------------------------------------------------------------
    # Data Processing & Querying
    # ------------------------------------------------------------------------
    jq # JSON query tool (like SQL for JSON)
    yq # YAML query tool (jq for YAML)
    dasel # Universal data selector (JSON/YAML/TOML/XML)
    grpcurl # curl for gRPC requests

    # ------------------------------------------------------------------------
    # Development Tools
    # ------------------------------------------------------------------------
    shellcheck # Bash script linter (catches common mistakes)
    pre-commit # Git pre-commit hook manager
    pkg-config-unwrapped # Build configuration helper
    cmake # Cross-platform build system
    ninja # Fast build system (used with cmake)
    doxygen # Documentation generator

    # ------------------------------------------------------------------------
    # Git Tools
    # ------------------------------------------------------------------------
    gh # GitHub CLI (create PRs, issues from terminal)
    bfg-repo-cleaner # Remove sensitive data from git history
    act # Run GitHub Actions locally
    lazygit # Terminal UI for git (visual git client)
    git-town # Git workflow automation

    # ------------------------------------------------------------------------
    # Cloud & DevOps
    # ------------------------------------------------------------------------
    s3cmd # Amazon S3 command-line tool
    docker # Container runtime
    docker-credential-helpers # Secure Docker credential storage
    qemu # Virtual machine emulator
    kubernetes-helm # Kubernetes package manager
    kustomize # Kubernetes configuration customization

    # ------------------------------------------------------------------------
    # Security & Encryption
    # ------------------------------------------------------------------------
    gnupg # GPG encryption (for signing commits, encrypting files)
    openssh # SSH client (for remote servers)
    ssh-agents # SSH agent management

    # ------------------------------------------------------------------------
    # Documentation & Markdown
    # ------------------------------------------------------------------------
    glow # Render markdown in terminal (beautiful!)

    # ------------------------------------------------------------------------
    # IDEs & Editors
    # ------------------------------------------------------------------------
    helix # Modern modal editor (like Vim but simpler)
    jetbrains.idea # IntelliJ IDEA (best IDE for JVM languages)
    obsidian # Markdown note-taking app (knowledge management)

    # ------------------------------------------------------------------------
    # API Tools
    # ------------------------------------------------------------------------
    # bruno # Postman alternative - moved to work-specific packages

    # ------------------------------------------------------------------------
    # AI Tools
    # ------------------------------------------------------------------------
    ollama # Run LLMs locally (Llama, Mistral, etc.)
    claude-code # Claude AI coding assistant

    # ------------------------------------------------------------------------
    # Static Site Generators
    # ------------------------------------------------------------------------
    zola # Fast static site generator (Rust-based)

    # ------------------------------------------------------------------------
    # Utilities
    # ------------------------------------------------------------------------
    jump # Fast directory navigation
    gettext # Internationalization tools
    dialog # Terminal UI dialogs
    zstd # Compression tool (faster than gzip)

    # ------------------------------------------------------------------------
    # Language Runtimes
    # ------------------------------------------------------------------------
    nodejs_24 # Node.js JavaScript runtime

    # ------------------------------------------------------------------------
    # Commented Out Packages
    # ------------------------------------------------------------------------
    # These are disabled but kept for reference

    # lima: Linux virtual machines on macOS (like Docker Desktop)
    # Commented because it's heavy and not always needed
    # lima

    # podman: Docker alternative (rootless containers)
    # Commented because we're using docker instead
    # podman

    # curl with Netskope certificates:
    # Example of how to override a package to add company certificates
    # Uncomment and customize if needed for your company network
    # (curl.overrideAttrs (old: {
    #   configureFlags = old.configureFlags ++ [
    #     "--with-ca-bundle=/Library/Application\\ Support/Netskope/STAgent/download/nscacert_combined.pem"
    #   ];
    # }))
  ];

  # ==========================================================================
  # Git-Specific Packages
  # ==========================================================================
  # Additional git tools that not everyone might need.
  # Separated for easier management.
  gitPkgs = with pkgs; [
    diff-so-fancy # Make git diffs beautiful and readable
    git-crypt # Encrypt files in git repos
    git-lfs # Git Large File Storage (for binary files)
  ];
in {
  # ==========================================================================
  # Program Configurations
  # ==========================================================================
  # These entries use Home Manager's "programs" option which:
  # 1. Installs the program
  # 2. Generates configuration files
  # 3. Sets up shell integration
  programs = {
    # ------------------------------------------------------------------------
    # Home Manager Self-Management
    # ------------------------------------------------------------------------
    # Allow home-manager to manage itself
    # This enables `home-manager switch` command
    home-manager.enable = true;

    # ------------------------------------------------------------------------
    # Direnv - Automatic Environment Switching
    # ------------------------------------------------------------------------
    # Automatically loads .envrc files when you cd into a directory
    # Useful for per-project environment variables and Nix shells
    #
    # EXAMPLE .envrc:
    #   use flake .#jdk17
    #   export DATABASE_URL=postgres://localhost/mydb
    direnv = {
      enable = true;
      nix-direnv.enable = true; # Better Nix support
    };

    # ------------------------------------------------------------------------
    # FZF - Fuzzy Finder
    # ------------------------------------------------------------------------
    # Ctrl+R: Search command history
    # Ctrl+T: Find files
    # Alt+C: cd into directory
    fzf = {
      enable = true;
      enableFishIntegration = true; # Add keybindings to fish shell
    };

    # ------------------------------------------------------------------------
    # Starship - Cross-Shell Prompt
    # ------------------------------------------------------------------------
    # Beautiful, fast, and customizable shell prompt
    # Shows git status, language versions, battery, etc.
    starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        # Don't show package version in prompt (reduces clutter)
        package.disabled = true;

        # Truncate directory path to show only repo root
        # /home/user/code/myproject → myproject
        directory.truncate_to_repo = true;
      };
    };
  };

  # ==========================================================================
  # Package Installation
  # ==========================================================================
  # Combine all package lists and install them.
  #
  # SYNTAX EXPLANATION:
  #   defaultPkgs ++ gitPkgs ++ [ ... ]
  #   - ++: List concatenation operator
  #   - Combines: default packages + git packages + company tools
  home.packages =
    defaultPkgs
    ++ gitPkgs;
  # Company-specific packages are added via extraPackages in work repo
}
