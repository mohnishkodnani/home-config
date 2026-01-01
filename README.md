# Modular Nix Home Manager Configuration

A highly modular, well-documented Nix home-manager configuration with profile system, custom JDK management, and extensive beginner-friendly documentation.

## 🌟 Features

- **Profile System**: Separate work and personal configurations
- **JDK Abstraction**: Seamlessly switch between nixpkgs JDKs and custom/company JDKs
- **Modular Architecture**: Reusable modules for git, neovim, fish, packages, etc.
- **Development Shells**: Per-project environments with specific Java versions
- **Library Functions**: Export `lib.mkHomeConfig` for use in other flakes
- **Extensive Documentation**: Assumes zero Nix knowledge, explains everything

## 📋 Table of Contents

- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Usage](#usage)
  - [As a Standalone Configuration](#as-a-standalone-configuration)
  - [As a Library (Public/Private Repo Split)](#as-a-library-publicprivate-repo-split)
- [Profile System](#profile-system)
- [Development Shells](#development-shells)
- [Customization](#customization)
- [For Nix Beginners](#for-nix-beginners)
- [Contributing](#contributing)

## 🚀 Quick Start

### Prerequisites

1. Install Nix (with flakes enabled):
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

2. Install home-manager:
   ```bash
   nix run home-manager/master -- init --switch
   ```

### Basic Usage

1. Clone this repository:
   ```bash
   git clone https://github.com/mohnishkodnani/home-config.git ~/.config/home-manager
   cd ~/.config/home-manager
   ```

2. Edit `profiles/personal.nix` with your information:
   ```nix
   user = {
     name = "Your Full Name";
     email = "you@example.com";
     username = "yourusername";
   };
   ```

3. Build and activate:
   ```bash
   home-manager switch --flake .#personal-linux
   ```

## 📁 Project Structure

```
.
├── flake.nix                      # Main flake entry point
├── flake-parts/                   # Modular flake configuration
│   ├── home-configurations.nix    # Machine configs + lib.mkHomeConfig
│   ├── devshells.nix             # Development environments
│   ├── packages.nix              # Package catalog
│   └── overlays.nix              # Package overlays
├── profiles/                      # Configuration templates
│   ├── base.nix                  # Shared base settings
│   └── personal.nix              # Personal profile (EDIT THIS!)
├── modules/                       # Reusable home-manager modules
│   ├── jdk-manager.nix           # JDK abstraction layer
│   ├── development/              # Dev tool modules (JVM, Rust, Python, etc.)
│   └── programs/                 # Program configs (git, neovim, fish, etc.)
├── overlays/                      # Custom package modifications
│   └── default.nix               # VS Code extensions, macOS utils
└── scripts/                       # Utility scripts
    ├── default.nix               # Script imports
    └── gen-ssh-key.nix          # SSH key generator
```

## 💻 Usage

### As a Standalone Configuration

Use this repo directly for your personal home-manager configuration:

1. **Edit the profile**: Modify `profiles/personal.nix` with your details
2. **Customize packages**: Edit `flake-parts/packages.nix` to add/remove tools
3. **Configure programs**: Modify modules in `modules/programs/` (git, neovim, etc.)
4. **Activate**: Run `home-manager switch --flake .#personal-linux`

### As a Library (Public/Private Repo Split)

Use this as a base configuration and extend it with company-specific settings:

#### 1. **Public Repo** (this repo)

Contains:
- Base home-manager modules
- Profile system
- JDK manager (works with nixpkgs and custom JDKs)
- Generic development tools

#### 2. **Private Repo** (your company/work repo)

Create a private flake that imports this one:

```nix
{
  description = "Work home-manager configuration";

  inputs = {
    # Import this public config as a library
    base-config.url = "github:mkodnani/home-config";

    # Your company-specific inputs
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    company-jdk17.url = "git+ssh://git@github.company.com/...";
    company-tools.url = "git+ssh://git@github.company.com/...";

    # Follow nixpkgs for consistency
    base-config.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { base-config, company-jdk17, company-tools, ... } @ inputs:
    {
      homeConfigurations.work-macbook = base-config.lib.mkHomeConfig {
        system = "aarch64-darwin";
        username = "yourname";

        # Your work profile (in private repo)
        profile = import ./profiles/work.nix;

        # Company-certified JDKs
        customJdks = {
          inherit (inputs) company-jdk17;
        };

        # Company-specific packages
        extraPackages = [
          company-tools.packages.aarch64-darwin.your-tool
        ];

        # Company-specific modules (from your work repo, not base-config)
        # Example: ~/work/repos/your-work-config/scripts/
        extraModules = [
          (import ./scripts/maven-settings.nix)  # Maven internal repos
          (import ./scripts/s3cfg.nix)           # S3 credentials
          (import ./scripts/vpn-config.nix)      # Company VPN
        ];

        # Pass company tools to modules
        extraInputs = {
          company-tools = inputs.company-tools;
        };
      };
    };
}
```

**Benefits:**
- ✅ Share base config publicly (help others, get contributions)
- ✅ Keep company secrets private (JDKs, internal tools, credentials)
- ✅ DRY: No duplication between work and personal configs
- ✅ Easy updates: Pull latest base config changes

## 👤 Profile System

Profiles are configuration templates that define user-specific settings.

### Structure

```nix
{
  _base.stateVersion = "25.05";
  profile = "personal";

  user = {
    name = "Your Name";
    email = "you@example.com";
    username = "yourusername";
  };

  jdk = {
    source = "nixpkgs";  # or "company" for custom JDKs
    versions = {
      jdk17.enable = true;
      jdk21.enable = true;
    };
    default = "jdk21";
  };
}
```

### Available Profiles

- **personal.nix**: For personal machines, uses nixpkgs JDKs
- **work.nix**: (Private repo only) Company JDKs and tools

## 🔧 Development Shells

Isolated development environments for different Java versions:

```bash
# Personal shells (nixpkgs JDKs)
nix develop .#jdk17        # Java 17 + Scala + Maven
nix develop .#jdk21        # Java 21 + Gradle
nix develop .#scala        # Full Scala environment
nix develop .#nix          # Nix development tools

# Work shells (company JDKs) - available in work configurations
nix develop .#work-jdk17   # Company-certified Java 17
nix develop .#work-jdk21   # Company-certified Java 21
```

**Auto-activation with direnv:**

Create `.envrc` in your project:
```bash
use flake .#jdk17
```

Automatically loads the environment when you `cd` into the directory!

## 🎨 Customization

### Adding Packages

Edit `flake-parts/packages.nix`:

```nix
defaultPkgs = with pkgs; [
  # Add your packages here
  ripgrep
  fzf
  my-custom-tool
];
```

### Configuring Programs

Modules in `modules/programs/` are automatically loaded. Create new ones:

```nix
# modules/programs/my-tool.nix
{ config, pkgs, profile, ... }:
{
  programs.my-tool = {
    enable = true;
    settings = {
      user = profile.user.name;
    };
  };
}
```

Then add to `flake-parts/home-configurations.nix`:

```nix
homeModules = {
  # ... existing modules
  my-tool = import ../modules/programs/my-tool.nix;
};
```

### Custom JDKs

To use custom JDKs instead of nixpkgs:

```nix
base-config.lib.mkHomeConfig {
  system = "aarch64-darwin";
  profile = myProfile;
  username = "myuser";

  # Provide custom JDK flakes
  customJdks = {
    jdk17 = inputs.my-custom-jdk17;
    jdk21 = inputs.my-custom-jdk21;
  };
}
```

The JDK manager automatically uses custom JDKs when `profile.jdk.source = "company"`.

### Work-Specific Scripts

The public repo does NOT include work/company-specific scripts. Implement these in your private work repo:

**Common Examples:**
- **Maven Settings:** Configure internal artifact repositories
- **S3 Config:** Cloud storage credentials
- **VPN Config:** Company VPN settings
- **Certificates:** Internal CA certificates

**Implementation Pattern:**

1. Create module in your work repo:
   ```nix
   # work-repo/scripts/maven-settings.nix
   {pkgs, ...}: {
     home.file.".m2/settings.xml".source = ./settings.xml;
   }
   ```

2. Import via extraModules:
   ```nix
   base-config.lib.mkHomeConfig {
     # ...
     extraModules = [
       (import ./scripts/maven-settings.nix)
     ];
   }
   ```

3. Encrypt sensitive files with git-crypt:
   ```bash
   # In work repo's .gitattributes
   scripts/settings.xml filter=git-crypt diff=git-crypt
   scripts/s3cfg* filter=git-crypt diff=git-crypt
   ```

See `CLAUDE.md` "Work-Specific Scripts Pattern" section for detailed examples.

## 📚 For Nix Beginners

### What is Nix?

Nix is a package manager that ensures **reproducible** and **declarative** system configurations. You describe what you want, Nix figures out how to build it.

### What is Home Manager?

Home Manager brings Nix's declarative approach to your user environment:
- Manage dotfiles (`.gitconfig`, `.zshrc`, etc.)
- Install and configure programs
- Keep everything in sync across machines

### Key Concepts

#### Flakes

Modern Nix way to define reproducible projects. Think `package.json` or `Cargo.toml` for Nix.

#### Profiles

Templates with user-specific settings (email, name, preferences).

#### Modules

Reusable configuration chunks. Like plugins that configure specific tools.

#### Dev Shells

Isolated environments with specific tools/versions. Like Python vir tualenvs but for any language.

### Common Commands

```bash
# Build configuration (doesn't activate)
nix build .#homeConfigurations.personal-linux.activationPackage

# Activate configuration
home-manager switch --flake .#personal-linux

# Enter development shell
nix develop .#jdk17

# Update all inputs (nixpkgs, etc.)
nix flake update

# See what's in the flake
nix flake show

# Format Nix code
alejandra .
```

### Learning Resources

- [Nix Pills](https://nixos.org/guides/nix-pills/) - Deep dive into Nix
- [Home Manager Manual](https://nix-community.github.io/home-manager/) - Official docs
- [Flakes](https://nixos.wiki/wiki/Flakes) - Understanding flakes
- [This repo's code](.) - Extensively documented, read the comments!

## 🤝 Contributing

Contributions welcome! This repo is designed to be:
- **Educational**: Help others learn Nix
- **Modular**: Easy to extend and customize
- **Well-documented**: Explain the "why", not just the "what"

### Guidelines

1. **Document everything**: Assume reader has zero Nix knowledge
2. **Use comments liberally**: Explain Nix concepts inline
3. **Keep it modular**: One concern per module
4. **Test before submitting**: Ensure `nix flake check` passes
5. **Follow existing style**: Use `alejandra` for formatting

## 📝 License

MIT License - feel free to use and modify!

## 🙏 Acknowledgments

- [Nix community](https://nixos.org/community/) for excellent tools and documentation
- [Home Manager](https://github.com/nix-community/home-manager) maintainers
- [flake-parts](https://flake.parts/) for modular flake structure
- Everyone who contributes to the Nix ecosystem

---

**Questions?** Open an issue!
**Found this helpful?** Star the repo!
**Want to contribute?** PRs welcome!
