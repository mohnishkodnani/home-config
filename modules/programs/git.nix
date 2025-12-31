{
  config,
  pkgs,
  profile,
  lib,
  ...
}: {
  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = profile.user.name;
    userEmail = profile.user.email;
    ignores = [
      "*.bloop"
      "*.bsp"
      "*.metals"
      "*.metals.sbt"
      "*metals.sbt"
      "*.direnv"
      "*.envrc" # there is lorri, nix-direnv & simple direnv; let people decide
      "*hie.yaml" # ghcide files
      "*.mill-version" # used by metals
      "*.jvmopts" # should be local to every project
      "*.idea"
      "*.ipr"
      "*.iml"
      ".DS_Store"
    ];
    extraConfig = {
      init.defaultBranch = "main";
      http.sslVerify = false;
      core = {
        editor = "nvim";
        pager = "diff-so-fancy | less --tabs=4 -RFX";
      };
      # URL rewrites for company GitHub (if configured in profile)
      url = lib.optionalAttrs (profile ? git.hosts.companyGithub) {
        "git@${profile.git.hosts.companyGithub}:" = {
          insteadOf = "https://${profile.git.hosts.companyGithub}/";
        };
      };
      pull = {
        rebase = false;
      };
      diff = {
        tool = "nvimdiff";
        algorithm = "patience";
      };
      difftool = {
        prompt = false;
        nvimdiff = {
          cmd = "nvim -d \"$LOCAL\" \"$REMOTE\"";
        };
      };
      merge = {
        tool = "nvimdiff";
        conflictstyle = "merge";
      };
      mergetool = {
        prompt = false;
        keepBackup = false;
        nvimdiff = {
          cmd = "nvim -d \"$LOCAL\" \"$REMOTE\" \"$MERGED\" -c '$wincmd w' -c '$wincmd J'";
        };
      };
      commit = {
        gpgsign = profile.git.signing or true;
      };
    };
  };
}
