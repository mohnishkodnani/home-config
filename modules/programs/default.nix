{
  config,
  pkgs,
  lib,
  oxalica,
  ...
}: let
  defaultPkgs = with pkgs; [
    nix-your-shell # Rust nix shell
    bat # a better cat
    eza # a better ls
    fzf # fuzzy file finder
    ripgrep # grep replacement
    bottom # a better top
    neofetch # display system information on shell.
    tmux # terminal emulator
    nix-prefetch-git # tool to help get nix sha hashes for builds
    grpcurl # curl for grpc requests
    yq # yaml query tool
    jq # json query tool
    dasel # data selector, jq & yq replacement
    fd # alternative to find
    shellcheck # bash shell script checker
    pkg-config-unwrapped
    cmake
    ninja
    doxygen
    #### Git tools
    gh # github cli
    bfg-repo-cleaner # github history cleaner
    act # test github actions locally.
    lazygit # Git TUI

    jump
    s3cmd
    gnupg # gpg
    gettext
    #    lima                  # Linux on MAC
    glow # terminal markdown reader
    nushell

    # Scala
    ammonite # REPL for scala
    sbt-extras # A more featureful runner for sbt, the simple/scala/standard build tool
    coursier # dependency downloader for scala & sbt
    scala-cli
    metals
    #    sbt

    # Build Tools
    maven # maven build tool for JVM
    # pre-commit # tool to run pre-commit hooks - commented out due to nodejs dependency
    gradle # Gradle build tool.

    # Java
    java-language-server # Java Language server for IDE LSP
    jdt-language-server
    visualvm # visual vm java analysis tool

    # k8s
    kubernetes-helm # helm package manager for k8s
    kustomize # k8s spec generation using templates

    # Nix
    #    nixd                  # Nix Language Server
    nixpkgs-fmt # nix code formatter
    nix-output-monitor # nix output monitor, better visualization of nix build outputs
    alejandra

    # Python
    python3 # Python 3
    python311Packages.python-lsp-server # python language server

    # SSH
    openssh # Open ssh to manage ssh keys
    ssh-agents # A single ssh-agent instead of eval

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
    # IDE
    helix # post modal editor `hx`
    # jetbrains.idea - Moved to devtools.nix
    # Debugging tools like lldb for rust and cpp
    lldb
    # rust based site generator
    zola
    #
    obsidian

    # override curl with Netskope
    #    (curl.overrideAttrs(old: {
    #      configureFlags = old.configureFlags ++ [ "--with-ca-bundle=/Library/Application\\ Support/Netskope/STAgent/download/nscacert_combined.pem"];
    #    }))
    # bruno # postman replacement - commented out due to nodejs dependency
    elixir
    livebook
    git-town

    #
    zstd
    #
    # cpp
    conan

    # Misc
    dialog
    ollama

    # nodejs_24  # Moved to other-languages.nix
    # claude-code  # May depend on nodejs
    vcpkg
    cmake-format

    zig
    zls
  ];

  gitPkgs = with pkgs; [
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
  home.packages =
    defaultPkgs
    ++ gitPkgs
    ++ [
      oxalica.packages.${pkgs.system}.nil
    ];
}
