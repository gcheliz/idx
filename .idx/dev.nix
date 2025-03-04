{ pkgs, ... }:

let
  customShell = pkgs.writeShellScript "custom-shell" '' 
    #!/usr/bin/env bash

    set -euo pipefail

    echo "Creating holded directory in $HOME"
    mkdir -p "$HOME/holded"

    echo "Cloning holded-app repository"
    if [ ! -d "$HOME/holded/holded-app" ]; then
      git clone https://github.com/holdedhub/holded-app "$HOME/holded/holded-app"
      if [ $? -ne 0 ]; then
        echo "Error cloning holded-app repository. Exiting."
        exit 1
      fi
    else
      echo "holded-app already cloned."
    fi

    echo "Navigating to holded-app directory"
    cd "$HOME/holded/holded-app"

    if [ -f "composer.json" ]; then
      echo "Installing composer dependencies"
        composer install
        if [ $? -ne 0 ]; then
          echo "Error installing composer dependencies. Exiting."
          exit 1
        fi
    fi

    if [ -f "package.json" ]; then
      echo "Installing yarn dependencies"
        yarn install
        if [ $? -ne 0 ]; then
          echo "Error installing yarn dependencies. Exiting."
          exit 1
        fi
    
        echo "Building with yarn"
          yarn build
        if [ $? -ne 0 ]; then
          echo "Error building with yarn. Exiting."
          exit 1
        fi
    } else {
        exit 1
      fi
    fi

    echo "Starting docker-compose"
    docker-compose up -d
    if [ $? -ne 0 ]; then
      echo "Error starting docker-compose. Exiting."
      exit 1 
    fi

    echo "Bootstrap finished!"
  '';
in
{
  packages = [
    pkgs.iputils
    pkgs.php82
    pkgs.php82Packages.composer
    pkgs.php82Extensions.mongodb
    pkgs.php82Extensions.redis
    pkgs.php82Extensions.opcache
    pkgs.php82Extensions.zlib
    pkgs.php82Extensions.bcmath
    pkgs.php82Extensions.zip
    pkgs.php82Extensions.soap
    pkgs.php82Extensions.xsl
    pkgs.php82Extensions.openssl
    pkgs.php82Extensions.apcu
    pkgs.php82Extensions.calendar
    pkgs.php82Extensions.curl
    pkgs.nginx
    pkgs.mongodb-6_0
    pkgs.redis
    pkgs.nodejs_latest
    pkgs.gh
    pkgs.git
    pkgs.curl  
    pkgs.yarn
    pkgs.docker
    pkgs.docker-buildx
    pkgs.docker-client
    pkgs.docker-compose
    pkgs.docker-credential-gcr
    pkgs.docker-credential-helpers
    pkgs.minikube
    pkgs.kubectl
    pkgs.terraform
    pkgs.terraform-docs
    pkgs.kustomize
    pkgs.helm
    pkgs.k9s
    pkgs.krew
    pkgs.google-cloud-sdk      
  ];
  services = {
    mongodb.enable = true;
    redis.enable = true;
  };
}
