{pkgs, ...}:
  pkgs.writeShellScriptBin "hm-list" ''
    echo "Available Home Manager configurations:"
    ${pkgs.nix}/bin/nix eval .#homeConfigurations --apply 'builtins.attrNames' --json --extra-experimental-features 'nix-command flakes' 2>/dev/null | ${pkgs.jq}/bin/jq -r '.[]' | sed 's/^/- /'
  ''
