{ config
  , pkgs
  , lib
  , ebayjdk11
  , tess
  , ebayjdk17
  , ...}:

let
  defaultPkgs = with pkgs; [
#    any-nix-shell         # nix shell
    nix-your-shell        # Rust nix shell
    bat                   # a better cat
    eza                   # a better ls
    fzf                   # fuzzy file finder
    ripgrep               # grep replacement
    bottom                # a better top
    neofetch              # display system information on shell.
    tmux                  # terminal emulator
    nix-prefetch-git      # tool to help get nix sha hashes for builds
    grpcurl               # curl for grpc requests
    yq                    # yaml query tool
    jq                    # json query tool
    dasel                 # data selector, jq & yq replacement
    fd                    # alternative to find
    shellcheck            # bash shell script checker
    #### Git tools
    gh                    # github cli
    bfg-repo-cleaner      # github history cleaner
    act                   # test github actions locally.
    lazygit               # Git TUI
    git-stack             # Git stack workflow

    jump
    s3cmd
    gnupg                 # gpg
    gettext
#    lima                  # Linux on MAC
    glow                  # terminal markdown reader
    nushell

    # Scala
#    ammonite              # REPL for scala
    sbt-extras            # A more featureful runner for sbt, the simple/scala/standard build tool
    coursier              # dependency downloader for scala & sbt
    scala-cli
    metals

    # Build Tools
    maven                 # maven build tool for JVM
    pre-commit            # tool to run pre-commit hooks
    gradle                # Gradle build tool.
    
    # Java
    java-language-server  # Java Language server for IDE LSP
    jdt-language-server
    visualvm              # visual vm java analysis tool

    # k8s
    kubernetes-helm       # helm package manager for k8s
    kustomize             # k8s spec generation using templates
    
    # Nix 
#    nixd                  # Nix Language Server
    nixpkgs-fmt           # nix code formatter
    nix-output-monitor    # nix output monitor, better visualization of nix build outputs
    
    # Python
    python3           # Python 3
    python311Packages.python-lsp-server     # python language server

    # SSH
    openssh               # Open ssh to manage ssh keys
    ssh-agents            # A single ssh-agent instead of eval
    
    # Go lang
    go

    # VM & Containers
#    podman
    qemu
    docker
    docker-credential-helpers

    # Rust
    cargo
    rust-analyzer
    rustc
    alejandra
    # IDE
    helix                 # post modal editor `hx`
    jetbrains.idea-ultimate # Best JVM IDE. Not yet supported on aarch
    # Debugging tools like lldb for rust and cpp
    lldb
    # rust based site generator
    zola
    # 
    obsidian
  ];
 
 gitPkgs = with pkgs.gitAndTools; [
   diff-so-fancy
   git-crypt
   git-lfs
 ];
in {
  programs = {
    home-manager.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    fzf = {
      enable = true;
      enableFishIntegration = true;
    };
    starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        package.disabled = true;
        directory.truncate_to_repo = true;
      };
    };
  };
  #ebayjdk11 = builtins.trace '' ${builtins.toJSON ebayjdk11.packages.aarch64-darwin.ebayjdk11} '' ebayjdk11;
  # gitPkgs = builtins.trace '' ${builtins.toJSON gitPkgs} '' gitPkgs;
  home.packages = defaultPkgs ++ gitPkgs ++ [ 
#    ebayjdk11.packages.aarch64-darwin.ebayjdk11 
    tess.packages.aarch64-darwin.tess 
#    ebayjdk17.defaultPackage.aarch64-darwin
  ];
}
