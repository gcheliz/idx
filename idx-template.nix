nix
{ pkgs, ... }:

let
  customShell = pkgs.writeShellScript "custom-shell" ''
    #!/usr/bin/env bash

    set -euo pipefail

    echo "Creating holded directory in $HOME"
    mkdir -p "$HOME/holded"

    echo "Installing gh"
    gh auth status || (echo "Authenticating gh" && gh auth login)

    echo "Installing gcloud"
    if ! command -v gcloud &> /dev/null; then
      echo "gcloud not found. Installing..."
      curl -sSL https://sdk.cloud.google.com | bash
      export PATH="$PATH:$HOME/google-cloud-sdk/bin"
      source "$HOME/google-cloud-sdk/path.bash.inc"
      source "$HOME/google-cloud-sdk/completion.bash.inc"
      echo "gcloud installed."
    else
      echo "gcloud already installed."
    fi
    
    # Initialize gcloud if not already initialized
    gcloud config list account --format='value(core.account)' &>/dev/null || (echo "gcloud not initialized. Initializing..." && gcloud init -q)

    echo "Installing docker"
    if ! command -v docker &> /dev/null; then
      echo "Docker not found. Attempting to install..."
      # Install Docker (this might need to be adjusted for different OSes)
      # This is a general example and might need to be adapted
      if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y docker.io
      elif command -v yum &> /dev/null; then
        sudo yum update
        sudo yum install -y docker
      else
        echo "Could not determine package manager. Please install Docker manually."
        exit 1
      fi
        echo "Docker Installed."
    else
      echo "Docker already installed."
    fi

    echo "Installing Minikube"
    if ! command -v minikube &> /dev/null; then
      echo "Minikube not found. Attempting to install..."
      # Install Minikube (this might need to be adjusted for different OSes)
      curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
      sudo install minikube-linux-amd64 /usr/local/bin/minikube
      rm minikube-linux-amd64
      echo "Minikube installed."
    else
      echo "Minikube already installed."
    fi

    echo "Installing kubectl"
    if ! command -v kubectl &> /dev/null; then
      echo "kubectl not found. Attempting to install..."
      curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
      sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
      rm kubectl
      echo "kubectl installed."
    else
      echo "kubectl already installed."
    fi

    echo "Installing terraform"
    if ! command -v terraform &> /dev/null; then
      echo "terraform not found. Please install it manually."
    else
      echo "Terraform already installed."
    fi

    echo "Installing kustomize"
    if ! command -v kustomize &> /dev/null; then
      echo "kustomize not found. Please install it manually."
    else
      echo "Kustomize already installed."
    fi

    echo "Installing helm"
    if ! command -v helm &> /dev/null; then
      echo "helm not found. Please install it manually."
    else
      echo "Helm already installed."
    fi

    echo "Installing task"
    if ! command -v task &> /dev/null; then
      echo "task not found. Please install it manually."
    else
      echo "Task already installed."
    fi

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

    echo "Installing composer dependencies"
    composer install
    if [ $? -ne 0 ]; then
      echo "Error installing composer dependencies. Exiting."
      exit 1
    fi

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
  osConfig = {
    shell = "${customShell} bash";
    mountHome = true;
  };

  devbox = {
    packages = [
      pkgs.php82
      pkgs.nginx
      pkgs.mongodb
      pkgs.redis
      pkgs.nodejs-23_x
      pkgs.gh
      pkgs.git
      pkgs.curl
      pkgs.docker-compose
      pkgs.composer
      pkgs.yarn
      pkgs.sudo # Add sudo package
    ];
  };
}
