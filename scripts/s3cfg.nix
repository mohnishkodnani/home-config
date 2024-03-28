{ pkgs, ...}:
let
  # TODO: git-crypt unlock first since maven settings has sensitive info. 
in {
    home.file.".s3cfg".source = ./s3cfg;
  }
