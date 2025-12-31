{
  config,
  pkgs,
  ...
}: let
  # Extensions from VS Code Marketplace
  vscode-extensions = pkgs.nix4vscode.forVscode [
    # RedHat extensions
    "redhat.vscode-yaml"
    "redhat.vscode-xml"
    "redhat.java"

    # Java development extensions
    "vscjava.vscode-java-debug"
    "vscjava.vscode-java-test"
    "vscjava.vscode-maven"
    "vscjava.vscode-java-dependency"
    "vscjava.vscode-gradle"
    "vscjava.vscode-spring-initializr"

    # Nix extensions (excluding problematic nix-ide)
    "bbenoist.nix"

    # GitHub extensions
    "github.copilot"
    "github.copilot-chat"
    "github.github-vscode-theme"

    # C/C++ and development tools
    "llvm-vs-code-extensions.vscode-clangd"
    "vadimcn.vscode-lldb"
    "twxs.cmake"
    "ms-vscode.cmake-tools"
    "mkhl.direnv"

    # Python
    "ms-python.python"

    # Language support
    "tamasfe.even-better-toml"
    "scala-lang.scala"
    "scalameta.metals"
    "rust-lang.rust-analyzer"
    "mathiasfrohlich.kotlin"

    # General productivity
    "vscodevim.vim"
    "tdennis4496.cmantic"
    "vivaxy.vscode-conventional-commits"
    "stoplight.spectral"
    "formulahendry.code-runner"
  ];

  # Extensions from OpenVSX registry (for problematic extensions)
  openvsx-extensions = pkgs.nix4vscode.forOpenVsx [
    "jnoortheen.nix-ide"
  ];

  # Combine all extensions
  custom-extensions = vscode-extensions ++ openvsx-extensions;
  code =
    if pkgs.stdenv.isLinux
    then pkgs.vscodium
    else pkgs.vscode;
in {
  programs.vscode = {
    enable = true;
    package = code;
    profiles.default.extensions = custom-extensions;
  };
}
