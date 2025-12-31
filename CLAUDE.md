# Nix Home Manager Base Configuration

This is a **public, reusable** Nix home-manager configuration designed to be used either standalone or as a library for other flakes.

## Architecture Overview

This repository can be used in two ways:

### 1. Standalone (Personal Use)
Clone and use directly for your personal home-manager configuration with standard nixpkgs JDKs.

### 2. Library (Public/Private Split)
Import this as a library in a private flake for company-specific configurations with custom JDKs and internal tools.

**Structure:**
```
Public Repo (this)          Private Repo (your company config)
├── lib.mkHomeConfig   ←────┤ Imports as library
├── Base modules            │ + Company JDKs
├── JDK manager             │ + Internal tools
├── Dev shells              │ + Work profile
└── Placeholder profile     └── + Company configs
```

See `work-repo-template/` for example private repo structure.

## Common Commands

### Building & Testing
```bash
# Show all flake outputs
nix flake show

# Build configuration (doesn't activate)
nix build .#homeConfigurations.personal-linux.activationPackage

# Activate configuration
home-manager switch --flake .#personal-linux

# Test library export
nix eval .#lib.mkHomeConfig --apply 'x: "Function exported successfully"'
```

### Development Shells
```bash
# Personal shells (nixpkgs JDKs)
nix develop .#jdk17           # Java 17 + Scala
nix develop .#jdk21           # Java 21
nix develop .#scala           # Full Scala environment
nix develop .#nix             # Nix dev tools

# Work shells (requires company JDK inputs - not available in public repo)
nix develop .#work-jdk17      # Company-certified JDK 17
nix develop .#work-jdk21      # Company-certified JDK 21
```

### Formatting & Linting
```bash
# Format all Nix files (MUST run before committing)
alejandra .

# Check syntax
nix flake check

# Format specific file
alejandra path/to/file.nix
```

## Repository Structure

```
.
├── flake.nix                      # Main entry (flake-parts based)
├── README.md                      # User-facing documentation
├── CLAUDE.md                      # This file (Claude Code instructions)
│
├── flake-parts/                   # Modular flake configuration
│   ├── home-configurations.nix    # Exports lib.mkHomeConfig + configs
│   ├── devshells.nix             # Personal & work dev shells
│   ├── packages.nix              # Package catalog
│   └── overlays.nix              # Package overlays
│
├── profiles/                      # Configuration templates
│   ├── base.nix                  # Shared settings (stateVersion)
│   ├── personal.nix              # PLACEHOLDER VALUES (safe for public)
│   └── work.nix                  # (NOT IN PUBLIC REPO)
│
├── modules/                       # Reusable home-manager modules
│   ├── jdk-manager.nix           # JDK abstraction layer
│   ├── development/              # Language tools (JVM, Rust, Python, etc.)
│   └── programs/                 # Program configs (git, neovim, fish, etc.)
│
├── overlays/                      # Custom package modifications
│   └── default.nix               # VS Code extensions, macOS utilities
│
├── scripts/                       # Utility scripts
│   ├── default.nix               # Custom scripts
│   ├── gen-ssh-key.nix          # SSH key generator
│   ├── maven-settings.nix       # (KEPT for private repos to extend)
│   └── s3cfg.nix                # (KEPT for private repos to extend)
│
└── work-repo-template/           # Example private repo structure
    ├── README.md                 # Work-specific instructions
    ├── CLAUDE.md                 # Work-specific Claude instructions
    ├── flake.nix                 # Imports this repo as library
    ├── profiles/work.nix         # Real work profile
    └── scripts/                  # Company-specific configs
```

## Code Style

### Documentation Requirements
- **ALWAYS assume zero Nix knowledge** - Explain everything
- Add `NIX LEARNING:` comments for Nix-specific concepts
- Document function parameters with types and examples
- Explain "why" not just "what"

### Formatting
- **MUST run `alejandra .` before committing** - Non-negotiable

### Naming Conventions
- Functions: `camelCase` (e.g., `mkHomeConfig`, `getJdk`)
- Modules: `kebab-case` (e.g., `jdk-manager.nix`, `darwin-application-activation.nix`)
- Profiles: `lowercase` (e.g., `work.nix`, `personal.nix`)

## Important Files & Concepts

### Library Export: `lib.mkHomeConfig`

**Location:** `flake-parts/home-configurations.nix`

**Purpose:** Main function that creates home-manager configurations. Exported for use by other flakes.

**Signature:**
```nix
mkHomeConfig = {
  system,                 # REQUIRED: "aarch64-darwin" | "x86_64-linux"
  profile,                # REQUIRED: Profile attribute set
  username,               # REQUIRED: Unix username
  customJdks ? null,      # OPTIONAL: Custom JDK flakes
  extraModules ? [],      # OPTIONAL: Additional modules
  extraPackages ? [],     # OPTIONAL: Additional packages
  extraInputs ? {},       # OPTIONAL: Inputs to pass to modules
}
```

**Example usage in private flake:**
```nix
inputs.base-config.lib.mkHomeConfig {
  system = "aarch64-darwin";
  profile = import ./work.nix;
  username = "myuser";
  customJdks = { inherit (inputs) company-jdk17 company-jdk21; };
  extraPackages = [ inputs.company-tool.packages.aarch64-darwin.default ];
  extraModules = [ (import ./company-config.nix) ];
  extraInputs = { company-tool = inputs.company-tool; };
}
```

### JDK Manager

**Location:** `modules/jdk-manager.nix`

**Purpose:** Abstracts JDK source (nixpkgs vs custom/company JDKs)

**How it works:**
- Reads `profile.jdk.source` ("nixpkgs" or "company")
- Provides `getJdk "17"` function that returns correct JDK
- Personal profile → nixpkgs JDK
- Work profile → company-certified JDK (if provided via `customJdks`)

### Profile System

**Required fields:**
```nix
{
  _base.stateVersion = "25.05";
  profile = "personal" | "work";
  user = { name, email, username };
  jdk = { source, versions, default };
}
```

**Public repo:**
- `profiles/personal.nix` - Placeholder values (safe to commit)
- NO `work.nix` (kept in private repos only)

**Usage in modules:**
```nix
{ profile, ... }:
{
  programs.git.userEmail = profile.user.email;
}
```

## Testing & Validation

### Before Committing
```bash
# 1. Format code
alejandra .

# 2. Check flake structure
nix flake check

# 3. Test builds (if you have the inputs)
nix build .#homeConfigurations.personal-linux.activationPackage --no-link

# 4. Test library export
nix eval .#lib.mkHomeConfig --apply 'x: "OK"'
```

### Testing Dev Shells
```bash
# Test personal shells work
nix develop .#jdk17 --command bash -c 'java -version'

# Test work shells (requires company JDK inputs - will fail in public repo)
nix develop .#work-jdk17 --command bash -c 'java -version'
```

## Gotchas & Known Issues

### 1. Work Shells Require Company Inputs
**Issue:** `nix develop .#work-jdk17` fails in standalone public repo

**Why:** Work shells need company JDK flake inputs (company-jdk17, etc.)

**Solution:** Only use personal shells (`jdk17`, `jdk21`) in public repo, or provide custom JDKs

### 2. Personal Profile Has Placeholders
**Issue:** `profiles/personal.nix` contains placeholder values

**Why:** Safe for public repo (no real email/name committed)

**Solution:**
- For standalone use: Edit `profiles/personal.nix` with your real info
- For library use: Create your own profile in private repo

## Maintaining CLAUDE.md

**IMPORTANT - Self-Improving Documentation:**

Always check if this file needs updates when you:
- Add new library functions
- Create new modules or major features
- Discover important patterns or gotchas
- Find solutions to common errors
- Change the public/private architecture

**How to update:**
1. Add to appropriate section
2. Keep examples beginner-friendly
3. Explain "why" not just "how"
4. Test examples before documenting

## For Nix Beginners

### Key Concepts

**Flakes:** Modern Nix way to define reproducible projects (like package.json)

**Home Manager:** Declaratively manage dotfiles and user environment

**Modules:** Reusable configuration chunks (like plugins)

**Profiles:** Configuration templates with user-specific settings

**Dev Shells:** Isolated environments with specific tools (like Python virtualenvs)

**flake-parts:** Framework for modular flake structure (avoids duplication)

### Learning Resources

- [README.md](./README.md) - Start here for usage examples
- [Nix Pills](https://nixos.org/guides/nix-pills/) - Deep dive into Nix
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [flake-parts Docs](https://flake.parts/)
- Code in this repo - Extensively documented with `NIX LEARNING:` comments

## Contributing

### For Public Repo Contributions

1. **Never commit secrets**
   - No real email addresses
   - No real names
   - No company-specific info

2. **Document everything**
   - Assume zero Nix knowledge
   - Add `NIX LEARNING:` comments
   - Explain why, not just what

3. **Format before committing**
   ```bash
   alejandra .
   nix flake check
   ```

4. **Test changes**
   ```bash
   nix build .#homeConfigurations.personal-linux.activationPackage
   ```

### Module Guidelines

- One concern per module
- Accept `profile` parameter
- Use `NIX LEARNING:` for Nix concepts
- Add to `homeModules` in `flake-parts/home-configurations.nix`

---

**Questions?** See README.md or open an issue
**Using as library?** See work-repo-template/ for examples
