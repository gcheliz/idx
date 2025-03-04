{ pkgs }:

{
  packages = pkgs.callPackage ({
    config = {
        allowUnfree = true;
    };
  }: [
    pkgs.php82
    pkgs.nginx    
    pkgs.mongodb
    pkgs.redis
    pkgs.nodejs
    pkgs.gh
    pkgs.git
    pkgs.curl
    pkgs.docker-compose
    pkgs.yarn
    pkgs.docker
    pkgs.minikube
    pkgs.kubectl
    pkgs.terraform
    pkgs.kustomize
    pkgs.helm    
  ];

  bootstrap = ''
    set -euo pipefail

    echo "Creating holded directory in $HOME"
    mkdir -p "$HOME/holded"

    if ! command -v yarn &> /dev/null; then
      echo "yarn not found. Attempting to install..."
      npm install --global yarn
      if [ $? -ne 0 ]; then
        echo "Error installing yarn. Exiting."
        exit 1
      fi
    else
      echo "Yarn already installed."
    fi

    if ! command -v composer &> /dev/null; then
      echo "Composer not found. Attempting to install..."
      curl -sS https://getcomposer.org/installer | php
      sudo mv composer.phar /usr/local/bin/composer
      echo "Composer installed"
    else
      echo "Composer already installed."
    fi

    echo "Starting docker-compose"
    docker-compose up -d
    if [ $? -ne 0 ]; then
      echo "Error starting docker-compose. Exiting."
      exit 1
    fi

    echo "Bootstrap finished!"
  '';
}
