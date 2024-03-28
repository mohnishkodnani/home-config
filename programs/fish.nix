{ config, pkgs, ...}:

let 

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
      eval (${pkgs.direnv}/bin/direnv hook fish)
      ${pkgs.nix-your-shell}/bin/nix-your-shell fish | source
      ${pkgs.starship}/bin/starship init fish | source
      ${pkgs.jump}/bin/jump shell fish | source
      ${pkgs.neofetch}/bin/neofetch
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
    functions = {
      proxyon = {
        description = ''Turn On Proxy'';
        body = ''
          echo "Enter pwd+yubi >"
          read -s token
          set -gx http_proxy http://mkodnani:$token@c2sproxy.vip.ebay.com
          set -gx https_proxy http://mkodnani:$token@c2sproxy.vip.ebay.com
          set -gx no_proxy reco.ebay.com,m3.ebay.com,ebayc3.com,corp.ebay.com,localhost,qa.ebay.com,esauth.stratus.dev.ebay.com,ah.stratus.dev.ebay.com
          echo "Proxy setup done"
        '';  
      };
      proxyoff = {
        description = ''Turn Off Proxy'';
        body = ''
          set -e http_proxy
          set -e https_proxy
          set -e no_proxy
          echo "Proxy settings cleared"
        '';  
      };
    };
    shellAliases = {
      ls = "eza";
      ll = "eza -lh --sort created";
      la = "eza -a";
      lla = "eza -lha";
      lt = "eza --tree";
      tree = "eza -tree";
      cat = "bat";
      catp = "bat -p --pager=''";
      k = "tess kubectl";
      k130 = "tess kubectl --cluster=130";
      k140 = "tess kubectl --cluster=140";
      kfcpd = "tess kubectl --cluster=fcp-dev";
      kfcpp = "tess kubectl --cluster=fcp-prod";
      bottom = "btm";
      gsm = "git switch main";
      gcam = "git commit -a -m -S";
      gpom = "git pull origin main";
      gsmas = "git switch master";
      gpomas = "git pull origin master";
    };
  };
}
