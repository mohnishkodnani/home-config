{pkgs, ...}: let
  # TODO: git-crypt unlock first since maven settings has sensitive info.
in {
  home.file.".s3cfg".source = ./s3cfg;
  home.file.".s3cfg_cassini_staging".source = ./s3cfg_cassini_staging;
}
