{
  pkgs,
  oxalica,
  ...
}: {
  # Nix Development Tools
  #
  # Tools for working with Nix language itself - formatters, language servers, utilities.
  #
  # Portability Note:
  # - We use ${pkgs.system} instead of hardcoding "aarch64-darwin"
  # - pkgs.system automatically resolves to: aarch64-darwin, x86_64-linux, etc.
  # - This makes the config work across different architectures and OSes

  home.packages =
    (with pkgs; [
      # Formatters
      # Different formatters have different code style preferences
      nixpkgs-fmt # Official nixpkgs formatter - conservative, stable
      alejandra # Opinionated formatter - modern style, faster

      # Build & Development Utilities
      nix-output-monitor # Better nix build output (the 'nom' command you use!)
      nix-your-shell # Integrates nix-shell with your shell for better UX
      nix-prefetch-git # Fetch git repos and compute their nix hashes
    ])
    ++ [
      # Nix Language Server from external flake
      # ${pkgs.system} evaluates to current system (e.g., "aarch64-darwin")
      # This works on Linux (x86_64-linux, aarch64-linux) and macOS too
      oxalica.packages.${pkgs.system}.nil
    ];
}
