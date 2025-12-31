{pkgs, ...}: let
  add = "${pkgs.openssh}/bin/ssh-add";
  agent = "${pkgs.openssh}/bin/ssh-agent";
  keygen = "${pkgs.openssh}/bin/ssh-keygen";
in
  pkgs.writeShellScriptBin "gen-ssh-key" ''
    mkdir -p "$HOME"/.ssh
    if [ $# -eq 0 ];
      then
        echo "No arguments provided, need email address and file name (id_rsa)"
        echo "gen-ssh-key username@email.com [id_rsa]"
      else
        if  [ -z "$1" ];
          then
           echo "No email address provided."
        else
          filename=id_ed25519
          if [ ! -z "$2" ]; then
            filename="$2"
          fi
          ${keygen} -q  -t ed25519 -C $1 -f "$HOME/.ssh/$filename" -N ""
          eval $(${agent} -s)
          ${add} -v $HOME/.ssh/"$filename"
        fi
    fi
  ''
