{ config, pkgs, ...}:

{
  programs.ssh = {
    enable = true;
#    startAgent = true;
    controlMaster = "auto";
    controlPersist = "300m";
    controlPath = "~/.ssh/masters/%h:%p";
    matchBlocks = {
      "github.corp.ebay.com" = {
        identityFile = "~/.ssh/id_githubcorp";
      };
      "github.com" = {
        identityFile = "~/.ssh/id_github";
      };
      "slcbastion300.slc.ebay.com" = {
      };
      "slcsearchsvc449-ql54h-tess0045.stratus.slc.ebay.com" = {
        identityFile = "~/.ssh/id_ed25519";
        proxyCommand  = "ssh slcbastion300.slc.ebay.com -W %h:%p";
      };
      "slcsearchsvc449-7v84b-tess0045.stratus.slc.ebay.com" = {
        identityFile = "~/.ssh/id_ed25519";
        proxyCommand  = "ssh slcbastion300.slc.ebay.com -W %h:%p";
      };
    };
  };
}
