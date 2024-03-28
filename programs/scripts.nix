{config, pkgs, ...}:

let 
  scripts = pkgs.callPackage ../scripts/default.nix { inherit pkgs;};
in {
  home.packages = scripts;
}
