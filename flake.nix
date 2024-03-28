{
  description = "Flake to manage software and home directory settings through nix home manager.";
  inputs = {
    # Package sets
    nixpkgs-master.url = github:NixOS/nixpkgs/master;
    nixpkgs-unstable.url = github:NixOS/nixpkgs/nixpkgs-unstable;

    # Home Manager
    home-manager.url = github:nix-community/home-manager;
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Neovim Nightly
#    neovim-nightly.url = github:nix-community/neovim-nightly-overlay;
#    neovim-nightly.inputs.nixpkgs.follows = "nixpkgs-unstable";
    # ebay JDK 11
    ebayjdk11.url = git+ssh://git@github.corp.ebay.com/mkodnani/flakes?ref=main&dir=ebayjdk11;
    ebayjdk11.inputs.nixpkgs.follows = "nixpkgs-unstable";
    
    # Tess Binary
    tess.url = git+ssh://git@github.corp.ebay.com/mkodnani/flakes?ref=main&dir=tess;
    tess.inputs.nixpkgs.follows = "nixpkgs-unstable";
 
    # Make Alias utility for MAC OS GUI Apps links to work with Finders.
    mkalias.url = github:reckenrode/mkalias;
    mkalias.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # ebay JDK 17
    ebayjdk17.url = git+ssh://git@github.corp.ebay.com/mkodnani/flakes?ref=main&dir=ebayjdk17;
    ebayjdk17.inputs.nixpkgs.follows = "nixpkgs-unstable";
    # Vs code extensions
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };
  
  outputs = { 
    self, 
    home-manager, 
#    neovim-nightly, 
    nixpkgs-unstable, 
    ebayjdk11, 
    tess, 
    ebayjdk17,
    nix-vscode-extensions,
    ...}@inputs:
    let
      # Some buidling blocks
      inherit (inputs.nixpkgs-unstable.lib) attrValues makeOverride optionalAttrs singleton;

      # Configuration for `nixpkgs`
      nixpkgsConfig = {
        config = { 
          allowUnfree = true;
          allowUnsupportedSystem = true;
          allowBroken = true;
        };
        overlays = overlays ++ singleton (

          # Sub in x86 version of packages that don't build on Apple Silicon yet
          final: prev: (optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
#            inherit (pkgs-x86-darwin) starship;
          })
          ) ++ singleton(
            final: prev: {
              fish = prev.fish.override {
#                fishEnvPreinit = source: source "/nix/var/nix/profiles/default/etc/profile.d/nix.sh";
              };
            }) ++ singleton(
		final: prev: {
#https://github.com/pecigonzalo/dotFiles/blob/dc809d16467a32500b67c9da478a8eb322ada2fd/flake.nix#L93
			mkalias = inputs.mkalias.outputs.apps.${prev.stdenv.system}.default.program;
		}
	  );
      };
      overlays = [
#        neovim-nightly.overlay
      ];
      # Create an override package to be used for apple silicon
      pkgs-x86-darwin = import nixpkgs-unstable {
        system = "x86_64-darwin";
        inherit (nixpkgsConfig) config;
      };
      pkgs = import nixpkgs-unstable {
        system = "aarch64-darwin";
        inherit (nixpkgsConfig) config;
        inherit (nixpkgsConfig) overlays;
      };
      # Home Manager State Version
      homeManagerStateVersion = "22.11";
      primaryUserInfo = {
        username = "mkodnani";
        email = "mkodnani@ebay.com";
        fullName = "Mohnish Kodnani";
        nixConfigDiretory = "/Users/mkodnani/.config/nixpkgs";
      };
    in {
      homeConfigurations = {
        macbook-pro-m1 = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs;
          modules = [
            {
              home = {
                username = primaryUserInfo.username;
                homeDirectory = "/Users/${primaryUserInfo.username}";
                stateVersion = homeManagerStateVersion;
              };
            }
          ] ++ attrValues self.homeManagerModules;
        };
      };
      homeManagerModules = {
        packages = import ./programs/default.nix {
          config = nixpkgsConfig.config;
          pkgs = pkgs;
          ebayjdk11 = ebayjdk11;
          tess = tess;
          lib = pkgs.lib;
          ebayjdk17 = ebayjdk17;
        };
        activation = import ./programs/darwin-application-activation.nix;
        git = import ./programs/git.nix;
        neovim = import ./programs/neovim/default.nix;
        fish = import ./programs/fish.nix;
        kitty = import ./programs/kitty/default.nix;
        fonts = import ./programs/fonts.nix;
        vscodium = import ./programs/vscode/default.nix {
          config = nixpkgsConfig.config;
          inherit pkgs;
          inherit inputs;
        };
        scripts = import ./programs/scripts.nix;
        ssh = import ./programs/ssh.nix;
        maven-settings = import ./scripts/maven-settings.nix;
        netrc = import ./scripts/netrc/default.nix;
        s3conf = import ./scripts/s3cfg.nix;
      };
      macbook-pro-m1 = self.homeConfigurations.macbook-pro-m1.activationPackage;
    };
}
