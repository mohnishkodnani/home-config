# ============================================================================
# HOME-CONFIGURATIONS.NIX - Machine-Specific Home Manager Configurations
# ============================================================================
#
# WHAT IS THIS FILE?
# ------------------
# This file defines HOME MANAGER CONFIGURATIONS for different machines
# (work macbook, work linux, personal linux, etc.). Each configuration
# determines:
# - Which packages are installed
# - Which dotfiles are created
# - Which programs are configured (git, neovim, fish shell, etc.)
#
# WHY SEPARATE CONFIGURATIONS?
# -----------------------------
# Different machines have different needs:
# - Work machines: Need company JDKs, company tools, work git config
# - Personal machines: Use nixpkgs JDKs, personal git config
# - macOS vs Linux: Different apps and system integration
#
# KEY CONCEPTS FOR NIX BEGINNERS:
# --------------------------------
# 1. PROFILES: Templates for work vs personal settings (see profiles/ directory)
#    - work.nix: Company JDKs, work email, company certificates
#    - personal.nix: Standard JDKs, personal email
#
# 2. HOME MODULES: Reusable chunks of configuration
#    - Like "plugins" that configure specific tools
#    - Example: git module configures ~/.gitconfig
#    - Example: neovim module configures ~/.config/nvim/
#
# 3. withSystem: A flake-parts helper that gives us the right 'pkgs' for
#    the target system (aarch64-darwin vs x86_64-linux)
#
# 4. attrValues: Converts a set to a list
#    Example: { a = 1; b = 2; } → [ 1 2 ]
#
# ============================================================================
# FUNCTION SIGNATURE EXPLANATION:
# { inputs, withSystem, ... }:
#   - inputs: All flake inputs (nixpkgs, home-manager, etc.)
#   - withSystem: flake-parts function to access system-specific pkgs
#   - ...: Any other arguments we don't need to name explicitly
{
  inputs,
  withSystem,
  ...
}: {
  # ==========================================================================
  # FLAKE-WIDE OUTPUTS
  # ==========================================================================
  # The "flake" attribute defines outputs that aren't system-specific.
  # Home configurations work across systems, so we define them here instead
  # of in perSystem.
  flake = let
    # Import helper functions from nixpkgs.lib
    # attrValues: Converts attribute set to list of values
    # Example: attrValues { a = 1; b = 2; } → [ 1 2 ]
    inherit (inputs.nixpkgs.lib) attrValues;

    # ==========================================================================
    # nixpkgs Configuration
    # ==========================================================================
    # These settings apply to ALL home configurations.
    # They control what kinds of packages we're willing to install.
    nixpkgsConfig = {
      config = {
        # Allow proprietary/closed-source software
        # Examples: VS Code, Obsidian, JetBrains IDEs
        allowUnfree = true;

        # Allow packages that might not officially support this OS
        # Sometimes they work anyway!
        allowUnsupportedSystem = true;

        # Allow packages marked as "broken" in nixpkgs
        # Useful when maintainers mark something broken but it still works
        allowBroken = true;
      };

      # Apply our custom package overlays
      # Overlays modify or add packages (VS Code extensions, macOS utilities)
      overlays = import ../overlays/default.nix {inherit inputs;};
    };

    # ==========================================================================
    # mkHomeConfig - Library Function to Create Home Manager Configurations
    # ==========================================================================
    # This is the MAIN LIBRARY FUNCTION that creates a complete home manager
    # configuration. It's designed to be imported and used by other flakes.
    #
    # WHY THIS EXISTS:
    # - Allows splitting config into public (base) and private (company) repos
    # - Provides a composable API for building custom home configurations
    # - Encapsulates complexity of profile system, JDK management, modules
    # - Leverages flake-parts' withSystem for proper system handling
    #
    # NIX LEARNING - FUNCTION SIGNATURE:
    # mkHomeConfig = {
    #   system,                  # REQUIRED: "aarch64-darwin" or "x86_64-linux"
    #   profile,                 # REQUIRED: Profile attribute set
    #   username,                # REQUIRED: Unix username
    #   customJdks ? null,       # OPTIONAL: Custom JDK flake inputs
    #   extraModules ? [],       # OPTIONAL: Additional home-manager modules
    #   extraPackages ? [],      # OPTIONAL: Additional packages to install
    #   extraInputs ? {},        # OPTIONAL: Extra flake inputs (company tools, etc.)
    # }
    #
    # NIX LEARNING - EXAMPLE USAGE (in another flake):
    # ```nix
    # inputs.base-config.url = "github:mkodnani/home-config";
    #
    # outputs = { base-config, ... }:
    #   homeConfigurations.my-machine = base-config.lib.mkHomeConfig {
    #     system = "aarch64-darwin";           # Your system architecture
    #     profile = import ./my-profile.nix;   # Your custom profile
    #     username = "myuser";                 # Your username
    #
    #     # Optional: provide custom JDKs
    #     customJdks = {
    #       inherit (inputs) company-jdk17 company-jdk21;
    #     };
    #
    #     # Optional: add company tools
    #     extraPackages = [
    #       inputs.company-tool.packages.aarch64-darwin.default
    #     ];
    #
    #     # Optional: add company-specific modules (from work repo)
    #     extraModules = [
    #       (import ./scripts/maven-settings.nix)  # Maven internal repos
    #       (import ./scripts/s3cfg.nix)           # S3 credentials
    #     ];
    #   };
    # ```
    #
    # NIX LEARNING - HOW withSystem WORKS:
    # Instead of manually creating pkgs for each system, we use flake-parts'
    # withSystem function. It automatically provides the correct pkgs based on
    # the system parameter, with all our overlays and config already applied.
    #
    # INTERNAL FLOW:
    #   1. Use withSystem to get system-specific pkgs (auto-configured)
    #   2. Validate profile has required fields
    #   3. Set up JDK manager with custom JDKs if provided
    #   4. Create home-manager configuration with all modules
    #   5. Merge extraModules and extraPackages from caller
    mkHomeConfig = {
      system,
      profile,
      username,
      customJdks ? null,
      extraModules ? [],
      extraPackages ? [],
      extraInputs ? {},
    }:
    # ========================================================================
    # Use withSystem to get system-specific pkgs
    # ========================================================================
    # NIX LEARNING: withSystem is provided by flake-parts. It's a function
    # that takes a system string ("aarch64-darwin") and a function that
    # receives system-specific outputs.
    #
    # The magic: pkgs is automatically provided with all our overlays and
    # config from perSystem in flake.nix already applied!
    #
    # Before withSystem (manual, error-prone):
    #   pkgs = import inputs.nixpkgs {
    #     inherit system;
    #     config = { allowUnfree = true; ... };
    #     overlays = [ ... ];
    #   };
    #
    # With withSystem (automatic, DRY):
    #   withSystem system ({ pkgs, ... }: ...)
    #   # pkgs already has everything configured!
      withSystem system ({pkgs, ...}: let
        # ----------------------------------------------------------------------
        # Profile Validation
        # ----------------------------------------------------------------------
        # NIX LEARNING: We validate that the profile has required fields to
        # provide helpful error messages. This makes debugging much easier.
        #
        # builtins.hasAttr checks if an attribute exists in a set.
        # builtins.filter creates a new list with only matching elements.
        requiredFields = ["_base" "user" "jdk"];
        missingFields =
          builtins.filter
          (field: !(builtins.hasAttr field profile))
          requiredFields;
        # NIX LEARNING: assert throws an error if the condition is false.
        # The || operator means "or" - if left side is true, right side is skipped.
        # We use throw to provide a detailed error message.
      in
        assert (builtins.length missingFields == 0)
        || throw ''
          mkHomeConfig ERROR: Profile is missing required fields!

          Missing: ${builtins.toString missingFields}

          A profile must have these fields:
            - _base: { stateVersion = "25.05"; }
            - user: { name = "Full Name"; email = "user@example.com"; username = "user"; }
            - jdk: { source = "nixpkgs" or "company"; versions = {...}; default = "jdk17"; }

          Example minimal profile:
            {
              _base.stateVersion = "25.05";
              user = {
                name = "John Doe";
                email = "john@example.com";
                username = "john";
              };
              jdk = {
                source = "nixpkgs";
                versions.jdk17.enable = true;
                default = "jdk17";
              };
            }
        ''; let
          # --------------------------------------------------------------------
          # JDK Manager Setup
          # --------------------------------------------------------------------
          # NIX LEARNING: The JDK manager provides a getJdk function that
          # intelligently picks JDKs from either nixpkgs or customJdks.
          #
          # We pass customJdks (provided by caller) to the module, which
          # internally still calls it companyJdks for backward compatibility.
          jdkManager = import ../modules/jdk-manager.nix {
            inherit pkgs profile;
            companyJdks = customJdks; # customJdks is more generic name
            lib = pkgs.lib;
          };
        in
          # --------------------------------------------------------------------
          # Create the Home Manager Configuration
          # --------------------------------------------------------------------
          # NIX LEARNING: home-manager.lib.homeManagerConfiguration creates a
          # derivation that represents your entire home environment. When built,
          # it produces an "activationPackage" that sets up dotfiles, installs
          # packages, and configures programs.
          inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs; # Pass the nixpkgs package set

            # Modules: A list of configuration chunks that get merged together
            # NIX LEARNING: The ++ operator concatenates lists.
            # We combine base modules with extraModules from the caller.
            modules =
              [
                # ----------------------------------------------------------------
                # Base Home Configuration
                # ----------------------------------------------------------------
                {
                  home = rec {
                    # rec = "recursive" - allows attributes to reference each other
                    inherit username;

                    # Set home directory based on OS
                    # NIX LEARNING: pkgs.stdenv.isDarwin is true on macOS
                    homeDirectory =
                      if pkgs.stdenv.isDarwin
                      then "/Users/${username}"
                      else "/home/${username}";

                    # Home Manager state version
                    stateVersion = profile._base.stateVersion;

                    # Extra commands to run when activating
                    extraProfileCommands =
                      if pkgs.stdenv.isDarwin
                      then ''ln -s /nix/var/nix/profiles/default/etc/ssl $out/etc/''
                      else "";

                    # Add extra packages from caller
                    # NIX LEARNING: This allows injecting additional packages
                    # (like company tools) without modifying base config.
                    packages = extraPackages;
                  };
                }

                # ----------------------------------------------------------------
                # JDK Manager Module
                # ----------------------------------------------------------------
                jdkManager

                # ----------------------------------------------------------------
                # All Base Home Modules
                # ----------------------------------------------------------------
                {
                  imports = attrValues inputs.self.homeModules;

                  # NIX LEARNING: _module.args passes arguments to all modules.
                  # We merge extraInputs with profile to allow callers to pass
                  # custom inputs (company tools, etc.)
                  _module.args =
                    {
                      inherit profile;
                      # Default inputs for backward compatibility
                      inherit (inputs) oxalica;
                    }
                    // extraInputs; # NIX LEARNING: // merges attribute sets
                }
              ]
              ++ extraModules; # Add caller's extra modules
          }); # Close withSystem

    # ==========================================================================
    # mkPersonalConfig - Helper for Personal Machines (INTERNAL USE)
    # ==========================================================================
    # NIX LEARNING: This is an INTERNAL helper for THIS flake only.
    # It uses mkHomeConfig with personal profile settings.
    #
    # External flakes should use mkHomeConfig directly (exported as lib.mkHomeConfig).
    #
    # USAGE (internal):
    #   personal-macbook = mkPersonalConfig "aarch64-darwin";
    mkPersonalConfig = system:
      mkHomeConfig {
        inherit system;
        profile = import ../profiles/personal.nix;
        username = "yourusername"; # CHANGE THIS to your username
        # No customJdks - uses nixpkgs JDKs
        # No extraPackages - minimal setup
        # No extraModules - just base configuration
      };
  in {
    # ==========================================================================
    # EXPORTED LIBRARY FUNCTIONS
    # ==========================================================================
    # These functions are exported for use by other flakes.
    # This enables the public/private repo split architecture.
    #
    # NIX LEARNING: Other flakes can import this flake and use:
    #   inputs.base-config.lib.mkHomeConfig { ... }
    lib = {
      # Export the main configuration builder
      inherit mkHomeConfig;

      # NIX LEARNING: We could export more helpers here:
      # mkJdkManager = ...; (for standalone JDK management)
      # mkDevShell = ...;   (for creating dev shells)
    };
    # ==========================================================================
    # Home Configurations - Example Configurations
    # ==========================================================================
    # These are example configurations you can build and activate:
    #   home-manager switch --flake .#personal-macbook
    #   home-manager switch --flake .#personal-linux
    #
    # Each config is self-contained and includes all necessary packages,
    # dotfiles, and program configurations.
    #
    # IMPORTANT: Update the username in mkPersonalConfig before using!
    homeConfigurations = {
      # ------------------------------------------------------------------------
      # Personal Machines
      # ------------------------------------------------------------------------
      # These use the personal profile: nixpkgs JDKs, personal git config

      # Apple Silicon Mac (M1/M2/M3)
      personal-macbook = mkPersonalConfig "aarch64-darwin";

      # Intel/AMD Linux machine
      personal-linux = mkPersonalConfig "x86_64-linux";
    };

    # ==========================================================================
    # Home Modules - Reusable Configuration Chunks
    # ==========================================================================
    # These modules are imported by all home configurations.
    # Each module configures a specific aspect of the environment.
    #
    # MODULE TYPES:
    # 1. Development Modules: Install language-specific tools (JVM, Rust, etc.)
    # 2. Program Modules: Configure specific programs (git, neovim, fish)
    # 3. Package Module: Defines which packages to install
    homeModules = {
      # ------------------------------------------------------------------------
      # Package Management
      # ------------------------------------------------------------------------
      # Defines the list of packages to install in $HOME/bin
      # Examples: ripgrep, fzf, jq, docker, kubectl, etc.
      packages = import ./packages.nix;

      # ------------------------------------------------------------------------
      # Development Environment Modules
      # ------------------------------------------------------------------------
      # These install language-specific tools and compilers

      # JVM: Maven, Gradle, Scala tools (sbt, metals, coursier)
      jvm-dev = import ../modules/development/jvm.nix;

      # Nix: Formatters (nixpkgs-fmt, alejandra), language servers
      nix-dev = import ../modules/development/nix-tools.nix;

      # Rust: cargo, rustc, clippy, rustfmt
      rust-dev = import ../modules/development/rust.nix;

      # Python: pip, virtualenv, poetry
      python-dev = import ../modules/development/python.nix;

      # C/C++: gcc, clang, cmake, make
      cpp-dev = import ../modules/development/cpp.nix;

      # Other: Go, Node.js, Ruby, etc.
      other-lang-dev = import ../modules/development/other-languages.nix;

      # Dev Tools: IDEs, debuggers, profilers
      dev-tools = import ../modules/development/devtools.nix;

      # ------------------------------------------------------------------------
      # Program Configuration Modules
      # ------------------------------------------------------------------------
      # These create dotfiles and configure programs

      # macOS: Activate GUI apps so they appear in Spotlight/Finder
      activation = import ../modules/programs/darwin-application-activation.nix;

      # Git: Configures ~/.gitconfig with user info, aliases, etc.
      git = import ../modules/programs/git.nix;

      # Neovim: Configures ~/.config/nvim/ with plugins and LSP
      neovim = import ../modules/programs/neovim/default.nix;

      # Fish Shell: Configures ~/.config/fish/ with aliases and functions
      fish = import ../modules/programs/fish.nix;

      # Kitty Terminal: Configures ~/.config/kitty/ with themes
      kitty = import ../modules/programs/kitty/default.nix;

      # Fonts: Installs Nerd Fonts for terminal icons
      fonts = import ../modules/programs/fonts.nix;

      # VS Code: Installs extensions and configures settings
      vscodium = import ../modules/programs/vscode/default.nix;

      # Scripts: Custom utility scripts in $HOME/bin
      scripts = import ../modules/programs/scripts.nix;

      # SSH: Configures ~/.ssh/config with host shortcuts
      ssh = import ../modules/programs/ssh.nix;

      # Company-specific modules should be added via extraModules parameter.
      # Common examples: maven-settings.nix (internal repos), s3cfg.nix (S3 creds),
      # vpn-config.nix (company VPN). These live in your work repo, not here.
      # See CLAUDE.md "Work-Specific Scripts Pattern" section for examples.
    };
  };
}
