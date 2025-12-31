# JDK Manager Module
#
# Nix Learning Point - Abstraction Layer:
# This module abstracts JDK sourcing so the rest of the config doesn't need
# to know whether we're using company JDKs or nixpkgs JDKs.
#
# The `getJdk` function is the key abstraction - modules just call getJdk("17")
# and this module handles fetching from the correct source.
{
  pkgs,
  profile,
  companyJdks ? null, # Optional - only provided for work profiles
  lib,
  ...
}: let
  inherit (lib) mkIf filterAttrs mapAttrsToList removePrefix;

  # Nix Learning Point - Function Abstraction:
  # This function returns the correct JDK package based on profile configuration.
  #
  # Example: getJdk "17"
  #   - If profile.jdk.source == "company" → looks up JDK in companyJdks by version
  #   - If profile.jdk.source == "nixpkgs" → pkgs.jdk17
  #
  # For company JDKs, we search the companyJdks attrset for an attribute containing
  # the version number, so it works with any naming scheme (company-jdk17, custom-jdk17, etc.)
  getJdk = version: let
    jdkAttr = "jdk${version}";

    # Find company JDK attribute by looking for one that contains the version
    # Example: if version="17", matches "company-jdk17", "custom-jdk17", "jdk17", etc.
    findCompanyJdk = version:
      let
        matchingAttrs = lib.filterAttrs
          (name: _: lib.hasSuffix version name)
          companyJdks;
      in
        if lib.length (lib.attrNames matchingAttrs) == 0
        then throw "No company JDK found for version ${version} in provided companyJdks"
        else lib.head (lib.attrValues matchingAttrs);
  in
    if profile.jdk.source == "company"
    then
      if companyJdks == null
      then throw "Company JDKs requested but not provided! Check flake inputs."
      else (findCompanyJdk version).defaultPackage.${pkgs.system}
    else pkgs.${jdkAttr};

  # Filter to only enabled JDK versions from profile
  enabledVersions =
    filterAttrs
    (_name: config: config.enable)
    profile.jdk.versions;

  # Convert version keys (jdk8, jdk11, etc.) to just numbers (8, 11, etc.)
  versionNumbers =
    mapAttrsToList
    (name: _: removePrefix "jdk" name)
    enabledVersions;

  # Get the default JDK package
  defaultJdk = getJdk (removePrefix "jdk" profile.jdk.default);
in {
  # Export the getJdk function for use by other modules (dev shells, etc.)
  # This is the key output - other modules import this to get JDKs
  lib.getJdk = getJdk;

  # Install only the default JDK in home.packages
  # Other JDK versions are available through dev shells
  home.packages = [defaultJdk];

  # Set default JAVA_HOME
  home.sessionVariables = {
    JAVA_HOME = "${defaultJdk}";
  };

  # Debug info (can be removed later)
  home.file.".jdk-info".text = ''
    Profile: ${profile.profile}
    JDK Source: ${profile.jdk.source}
    Default JDK: ${profile.jdk.default}
    Enabled versions: ${toString versionNumbers}
    Default JAVA_HOME: ${defaultJdk}
  '';
}
