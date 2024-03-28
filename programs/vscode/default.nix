{ config, pkgs, inputs, ...}:
let
  exts = inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace;
  my-cmake-tools = exts.ms-vscode.cmake-tools.overrideAttrs (_: {sourceRoot = "extension";});
  custom-extensions = builtins.attrValues {
    inherit (exts.redhat) vscode-yaml vscode-xml java;
    inherit (exts.vscjava) vscode-java-debug vscode-java-test vscode-maven vscode-java-dependency vscode-gradle vscode-spring-initializr;
    inherit (exts.bbenoist) nix;
    inherit (exts.jnoortheen) nix-ide;
    inherit (exts.github) copilot copilot-chat github-vscode-theme;
    inherit (exts.llvm-vs-code-extensions) vscode-clangd;
    inherit (exts.vadimcn) vscode-lldb;
    inherit (exts.twxs) cmake;
    inherit (exts.mkhl) direnv;
    inherit (exts.ms-python) python;
    inherit (exts.tamasfe) even-better-toml;
    inherit (exts.scala-lang) scala;
    inherit (exts.scalameta) metals;
    inherit (exts.vscodevim) vim;
    inherit (exts.rust-lang) rust-analyzer;
    inherit (exts.tdennis4496) cmantic;
    inherit my-cmake-tools;
  };
  extensions = (with pkgs.vscode-extensions; [
    bbenoist.nix
    jnoortheen.nix-ide
    redhat.java
    redhat.vscode-yaml
    redhat.vscode-xml
    vscjava.vscode-java-debug
    vscjava.vscode-java-test
    vscjava.vscode-maven
    vscjava.vscode-java-dependency
    vscjava.vscode-gradle
    vscjava.vscode-spring-initializr
    github.copilot
    github.copilot-chat
#    vmware.vscode-spring-boot
#    vmware.vscode-boot-dev-pack
    llvm-vs-code-extensions.vscode-clangd
#    vadimcn.vscode-lldb # Error when compiling codelldb with clang 16, linker errors out.
    twxs.cmake
    mkhl.direnv
    ms-python.python
    ms-vscode.cmake-tools
    tamasfe.even-better-toml
    scala-lang.scala
    scalameta.metals
    vscodevim.vim
    rust-lang.rust-analyzer
#    zzzz.hocon-colorizer
  ]);
  code = if pkgs.stdenv.isLinux then pkgs.vscodium else pkgs.vscode;
in
{
  programs.vscode = {
    enable = true;
    package = code;
    extensions = custom-extensions; 
  };
}
