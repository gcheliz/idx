{ pkgs }:
{
  packages = [
    pkgs.nodejs 
    pkgs.gh
  ];

  bootstrap = ''
    set -euo pipefail

    mkdir -p "$HOME/holded"
    gh auth status || (echo "Authenticating gh" && gh auth login)

    if ! command -v yarn &> /dev/null; then
      echo "yarn not found. Attempting to install..."
      npm install --global yarn
      if [ $? -ne 0 ]; then
        echo "Error installing yarn. Exiting.";
        exit 1;
      fi;
    else 
      echo "Yarn already installed.";
    fi;
  '';
}
