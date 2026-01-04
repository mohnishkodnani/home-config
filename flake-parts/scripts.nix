{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    # Export our custom scripts as flake packages
    # This allows running them directly with 'nix run .#script-name'
    packages = {
      gen-ssh-key = pkgs.callPackage ../scripts/gen-ssh-key.nix {inherit pkgs;};
      hm-list = pkgs.callPackage ../scripts/hm-list.nix {inherit pkgs;};
    };
  };
}
