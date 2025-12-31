{
  config,
  pkgs,
  ...
}: let
in {
  programs.fish = {
    enable = true;
    loginShellInit = ''
            set -Ux NIX_REMOTE daemon
      #      ulimit -n 50000
            if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
              source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
            end
            set -gx PATH ~/.nix-profile/bin/ $PATH
            set -gx SHELL ~/.nix-profile/bin/fish
            ${pkgs.nix-your-shell}/bin/nix-your-shell fish | source
            ${pkgs.starship}/bin/starship init fish | source
            ${pkgs.jump}/bin/jump shell fish | source
            ${pkgs.neofetch}/bin/neofetch
            eval (${pkgs.direnv}/bin/direnv hook fish)
    '';
    plugins = with pkgs.fishPlugins; [
      {
        name = "foreign-env";
        src = foreign-env.src;
      }
      {
        name = "forgit";
        src = forgit.src;
      }
    ];
    # Custom functions can be added here
    # For work-specific functions (proxy, etc.), add them in work repo's extraModules
    functions = {};
    # Common shell aliases
    # For work-specific aliases, add them in work repo's extraModules
    shellAliases = {
      ls = "eza";
      ll = "eza -lh --sort created";
      la = "eza -a";
      lla = "eza -lha";
      lt = "eza --tree";
      tree = "eza -T";
      cat = "bat";
      catp = "bat -p --pager=''";
      bottom = "btm";
      gsm = "git switch main";
      gcam = "git commit -a -m -S";
      gpom = "git pull origin main";
      gsmas = "git switch master";
      gpomas = "git pull origin master";
    };
  };
}
