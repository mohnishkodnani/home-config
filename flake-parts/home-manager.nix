{inputs, ...}: {
  imports = [
    inputs.home-manager.flakeModules.default
  ];

  perSystem = {pkgs, ...}: {
    # Home Manager configurations can be defined here
  };
}
