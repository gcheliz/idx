nix
{ pkgs, ... }:

let
  customShell = pkgs.writeShellScript "custom-shell" '' 
    #!/usr/bin/env bash

    # Use set -euo pipefail to exit immediately if a command exits with a non-zero status

    #Flag to check if we cloned the repo
    cloned_repo=false

    set -euo pipefail

    echo "Creating holded directory in $HOME"
    mkdir -p "$HOME/holded"

    echo "Installing gh"
    gh auth status || (echo "Authenticating gh" && gh auth login)
    
    echo "Installing yarn"
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

    echo "Cloning holded-app repository"
    if [ ! -d "$HOME/holded/holded-app" ]; then
      git clone https://github.com/holdedhub/holded-app "$HOME/holded/holded-app"
      cloned_repo=true
      if [ $? -ne 0 ]; then
        echo "Error cloning holded-app repository. Exiting."
        exit 1
      fi
    else
      echo "holded-app already cloned."
    fi

    echo "Navigating to holded-app directory"
    cd "$HOME/holded/holded-app"

    echo "Installing composer dependencies"
    if [ "$cloned_repo" = true ]; then
      composer install
      if [ $? -ne 0 ]; then
        echo "Error installing composer dependencies. Exiting."
        exit 1
      fi
    fi

    echo "Installing yarn dependencies"
    if [ "$cloned_repo" = true ]; then
      yarn install
      if [ $? -ne 0 ]; then
        echo "Error installing yarn dependencies. Exiting."
        exit 1
      fi
    fi
    
    echo "Building with yarn"
    if [ "$cloned_repo" = true ]; then
      yarn build
      if [ $? -ne 0 ]; then
        echo "Error building with yarn. Exiting."
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
    sudo systemctl start docker
  '';
in
{
  packages = [
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
}
