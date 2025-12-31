{pkgs, ...}: let
  # Nix Learning Point: Let-binding for DRY principle
  # Extract python3 into a variable so we reference it once.
  # If we ever want to change to a specific version (python312, python313),
  # we only change it in one place.
  python = pkgs.python3;
in {
  # Python Development Tools

  home.packages = [
    python # Python 3 interpreter (currently 3.13)
    python.pkgs.python-lsp-server # LSP server for the same Python version
  ];
}
