#!/bin/bash

# Farben für die Ausgabe
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Keine Farbe

# Name des Repositories
REPO_URL="https://github.com/NiklasJavier/DevOpsToolkit.git"

# Variable zur Speicherung des Branch-Namens
BRANCH=""

# Funktion zum Anzeigen der Branch-Auswahl und Auswahl durch den Benutzer
choose_branch() {
    echo -e "${GREEN}Please select the branch to clone:${NC}"
    echo -e "1) ${BLUE}production${NC}"
    echo -e "2) ${YELLOW}staging${NC}"
    echo -e "3) ${RED}dev${NC}"
    read -p "Enter your choice (1-3):" choice < /dev/tty

    case $choice in
      1)
        BRANCH="production"
        ;;
      2)
        BRANCH="staging"
        ;;
      3)
        BRANCH="dev"
        ;;
      *)
        echo -e "${RED}Invalid choice. Exiting...${NC}"
        exit 1
        ;;
    esac
}

# Prüfen, ob -t Option angegeben wurde und Branch bestimmen
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -t)
      shift
      if [[ "$1" == "production" || "$1" == "staging" || "$1" == "dev" ]]; then
        BRANCH="$1"
      else
        echo -e "${RED}Invalid branch specified with -t. Please use 'production', 'staging', or 'dev'.${NC}"
        exit 1
      fi
      ;;
    *)
      echo -e "${RED}Invalid option: $1${NC}" >&2
      exit 1
      ;;
  esac
  shift
done

# Falls kein Branch angegeben wurde, den Benutzer fragen
if [ -z "$BRANCH" ]; then
    choose_branch
fi

# Verzeichnisname basierend auf Branch
CLONE_DIR="/etc/DevOpsToolkit-$BRANCH"

# Überprüfen, ob das Skript als Root ausgeführt wird
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root.${NC}"
    exit 1
fi

echo -e "${GREEN}Starting the setup for branch: $BRANCH...${NC}"

# Überprüfen, ob Git installiert ist
if ! command -v git &> /dev/null; then
    echo -e "${RED}Git is not installed. Installing Git...${NC}"
    sudo apt-get update
    sudo apt-get install -y git

    # Überprüfen, ob die Installation erfolgreich war
    if ! command -v git &> /dev/null; then
        echo -e "${RED}Git installation failed. Aborting...${NC}"
        exit 1
    else
        echo -e "${GREEN}Git installed successfully.${NC}"
    fi
else
    echo -e "${GREEN}Git is already installed.${NC}"
fi

# Verzeichnis erstellen, wenn es nicht existiert
if [ ! -d "$CLONE_DIR" ]; then
    echo -e "${GREEN}Creating directory $CLONE_DIR...${NC}"
    sudo mkdir -p "$CLONE_DIR"
fi

# Prüfen, ob das Repository bereits geklont wurde
if [ -d "$CLONE_DIR/.git" ]; then
    echo -e "${GREEN}Repository already exists. Pulling latest changes...${NC}"
    cd "$CLONE_DIR"
    sudo git pull
else
    echo -e "${GREEN}Cloning the repository into $CLONE_DIR with branch $BRANCH...${NC}"
    sudo git clone -b "$BRANCH" --single-branch "$REPO_URL" "$CLONE_DIR"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to clone the repository. Aborting...${NC}"
        exit 1
    fi
fi

# Alle Skripte ausführbar machen
echo -e "${GREEN}Making all scripts in $CLONE_DIR executable...${NC}"
sudo find "$CLONE_DIR" -type f -name "*.sh" -exec chmod +x {} \;

echo -e "${GREEN}Setup completed! Repository cloned to $CLONE_DIR and scripts are now executable.${NC}"
