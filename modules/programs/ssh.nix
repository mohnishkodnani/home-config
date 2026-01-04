{
  config,
  pkgs,
  profile,
  lib,
  ...
}: {
  # Basic SSH configuration
  # For work-specific host configurations, add a separate ssh module in your
  # work repository's extraModules
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    # Basic GitHub configuration
    matchBlocks = {
      "*" = {
        controlMaster = "auto";
        controlPath = "~/.ssh/masters/%h:%p";
        controlPersist = "300m";
      };
      "github.com" = {
        user = "git";
        identityFile = profile.git.sshKeys.github or "~/.ssh/id_github";
      };
    };
  };
}
