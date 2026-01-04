{
  pkgs,
  ...
}: let
  gen-ssh-key = pkgs.callPackage ./gen-ssh-key.nix {inherit pkgs;};
  hm-list = pkgs.callPackage ./hm-list.nix {inherit pkgs;};
in [
  gen-ssh-key # Generate ssh key and add it to the system.
  hm-list # List available home configurations.
]
