#!/bin/sh
set -euxo pipefail
set -o functrace
set -o errtrace

check_nix_install() {
  retval=0
  if ! command -v nix &> /dev/null
  then
    echo >&2 "No prior Nix installation detected..."
  else
    echo >&2 "Nix is already installed."
    retval=1
  fi
  echo "$retval"
}

check_direnv_installed() {
  retval=0
  if command -v direnv; then
    echo >&2 "direnv is already installed."
    retval=1
  else
    echo >&2 "direnv not installed."
  fi
  echo "$retval"
}
check_nix_installer_in_cwd() {
  retval=0
  if test -f "nix-installer"; then
    echo >&2 "Found Nix Installer in cwd."
    retval=1
  else
    echo >&2 "Could not find nix-installer in cwd."
  fi
  echo "$retval"
}
echo "Begin to setup system."
read -rep "Do you use Netskope that proxies any outgoing traffic? [y/n]: " is_netskope_used
if [ "$is_netskope_used" == "y" ]; then 
  read -rep "Please provide the full path to the Netskope certificate file : " netskope_cert
  echo "$netskope_cert file will be used to install and setup the system."
  export NIX_SSL_CERT_FILE="$netskope_cert"
  export SSL_CERT_FILE="$netskope_cert"
  export CURL_CA_BUNDLE="$netskope_cert"
  export REQUESTS_CA_BUNDLE="$netskope_cert"
fi
read -rep "Do you want to try the determinate system's rust installer, not official ? [y/n]: " use_determinate
retval=$(check_nix_install)
nix_installed=0
nix_install_cmd="$(pwd)/nix-installer --nix-extra-conf-file $(pwd)/nix.conf"
if [ "$retval" == 0 ]; then
  echo "Installing Nix"
  retval=$(check_nix_installer_in_cwd)
  if [ "$retval" == 0 ]; then
    if [ "$use_determinate" == "n" ]; then
#      curl -L https://nixos.org/nix/install -o nix-installer
      curl -L https://releases.nixos.org/nix/nix-2.13.3/install -o nix-installer
      chmod +x nix-installer
    else
      curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix -o nix-installer
      chmod +x ./nix-installer
      nix_install_cmd="./nix-install install --no-confirm"
    fi
  fi
  $($nix_install_cmd 1>&0)
  retval=$?
  if [ "$retval" == 1 ]; then
    echo "Something went wrong with nix install, please fix and follow instructions for nix-installer.sh script."
    exit 1
  else
    echo "Nix installation successful."
    nix_installed=1
  fi
fi
retval=$(check_direnv_installed)
if [ "$retval" == 0 ]; then
  echo "Installing direnv."
  curl -sfL https://direnv.net/install.sh -o direnv-installer.sh
  chmod +x direnv-installer.sh
  sudo ./direnv-installer.sh
  retval=$?
  if [ "$retval" == 1 ]; then 
    echo "Could not install direnv, please re-run the direnv-installer.sh script and fix any errors."
    exit 1
  fi
fi
read -rep "which machine/configuration do you want to build : " derivation
echo "Begin setting up the machine."
echo "Detected OS $OSTYPE."
if [ "$OSTYPE" == 'darwin'* ] && [ "$nix_installed" == 1 ]; then
  echo "Setting NIX_SSL_CERT_FILE using launchctl and restarting nix-daemon as per instructions at https://nixos.org/manual/nix/stable/installation/env-variables.html?highlight=NIX_SSL#nix_ssl_cert_file"
  sudo launchctl setenv NIX_SSL_CERT_FILE "$netskope_cert"
  sudo launchctl setenv SSL_CERT_FILE "$netskope_cert"
  sudo launchctl setenv CURL_CA_BUNDLE "$netskope_cert"
  sudo launchctl setenv REQUESTS_CA_BUNDLE "$netskope_cert"
  export NIX_USER_PROFILE_DIR=/nix/var/nix/profiles/per-user/$USER
  export NIX_REMOTE=daemon
  # copy netskope into nix root certificate
  sudo mv /nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt /nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt.backup
  cat $netskope_cert /nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt.backup >> /tmp/combined.pem
  sudo mv /tmp/combined.pem /nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt
  sudo chmod 755 /nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt
  ln -s $NIX_USER_PROFILE_DIR $HOME/.nix-profile
  sudo launchctl kickstart -k system/org.nixos.nix-daemon
  read -sp "Enter your corp password , I will put this in /etc/nix/netrc and you will have to change this file when you change corp password. This is used for artifactory access." corpPass
  echo "machine artifactory.qa.ebay.com login "$USER" password "$corpPass" | sudo tee -a /etc/nix/netrc > /dev/null
  #TODO: kickstart does not load new params, we need to unload the plist file and then load it again.
  #nix build github:mkodnani/home-config#homeConfigurations.derivation.activationPackage
  sudo nix build .#macbook-pro-m1
elif [ "$OSTYPE" == 'linux' ] && [ "$nix_installed" == 1 ]; then 
  echo "Setting NIX_SSL_CERT_FILE."
fi
