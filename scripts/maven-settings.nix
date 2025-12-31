{pkgs, ...}: let
  # TODO: git-crypt unlock first since maven settings has sensitive info.
in {
  home.file.".m2/settings.xml".source = ./settings.xml;
}
