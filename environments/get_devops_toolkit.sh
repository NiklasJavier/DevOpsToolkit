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
    echo "1) production"
    echo "2) staging"
    echo "3) dev"
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
CLONE_DIR="/etc/DevOpsToolkit"

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

# Prüfen, ob der branch-spezifische Ordner existiert, und erstellen, wenn nicht
BRANCH_DIR="$CLONE_DIR/environments/$BRANCH"
SETTINGS_DIR="$BRANCH_DIR/.settings"

if [ ! -d "$BRANCH_DIR" ]; then
    echo -e "${GREEN}Creating branch-specific folder: $BRANCH_DIR...${NC}"
    mkdir -p "$BRANCH_DIR"
else
    echo -e "${GREEN}Branch-specific folder already exists: $BRANCH_DIR...${NC}"
fi

# Prüfen, ob der .settings-Ordner existiert, und erstellen, wenn nicht
if [ ! -d "$SETTINGS_DIR" ]; then
    echo -e "${GREEN}Creating .settings folder in $BRANCH_DIR...${NC}"
    mkdir -p "$SETTINGS_DIR"
else
    echo -e "${GREEN}.settings folder already exists in $BRANCH_DIR...${NC}"
fi

# Alle Skripte ausführbar machen
echo -e "${GREEN}Making all scripts in $CLONE_DIR executable...${NC}"
sudo find "$CLONE_DIR" -type f -name "*.sh" -exec chmod +x {} \;

echo -e "${GREEN}Setup completed! Repository cloned to $CLONE_DIR and scripts are now executable.${NC}"

# Config file 
CONFIG_FILE="$SETTINGS_DIR/config.yaml"

# Funktion zur Initialisierung der Variablen durch den Benutzer oder Standardwerte
initialize_config() {
    echo -e "${GREEN}Initializing configuration...${NC}"

    # Verschieben der temporären Konfigurationsdatei
    mv "$CLONE_DIR/environments/config.temp.yaml" "$SETTINGS_DIR/config.yaml"

    # System Name festlegen (ehemals Hostname)
    if [ -z "$SYSTEM_NAME" ]; then
        random_string=$(pwgen -1 -A 8)
        default_system_name="SRVID-$random_string"
        read -p "Enter system name (default: $default_system_name): " SYSTEM_NAME
        SYSTEM_NAME=${SYSTEM_NAME:-"$default_system_name"}
    fi

    # SSH_PORT festlegen
    if [ -z "$SSH_PORT" ]; then
        read -p "Enter the SSH_PORT (default: 282): " SSH_PORT
        SSH_PORT=${SSH_PORT:-282}
    fi

    # Log Level festlegen
    if [ -z "$LOG_LEVEL" ]; then
        read -p "Enter the log level (default: info) [debug, info, warn, error]: " LOG_LEVEL
        LOG_LEVEL=${LOG_LEVEL:-"info"}
    fi

    # Datenverzeichnis festlegen, das auf dem Systemnamen basiert
    if [ -z "$DATA_DIR" ]; then
        default_data_dir="/var/$SYSTEM_NAME/data"
        read -p "Enter the data directory (default: $default_data_dir): " DATA_DIR
        DATA_DIR=${DATA_DIR:-"$default_data_dir"}
    fi

    # Konfiguration in config.yaml speichern
    echo -e "${GREEN}Saving configuration to $CONFIG_FILE...${NC}"

    # Speichern der Konfiguration
    cat <<- EOL > "$CONFIG_FILE"
system_name: "$SYSTEM_NAME"
ssh_port: $SSH_PORT
log_level: "$LOG_LEVEL"
data_dir: "$DATA_DIR"
EOL

    echo -e "${GREEN}Configuration saved in $CONFIG_FILE.${NC}"
}

# Prüfen, ob die config.yaml existiert, und initialisieren, falls nicht vorhanden
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${GREEN}$CONFIG_FILE not found. Initializing configuration...${NC}"
    initialize_config
else
    echo -e "${GREEN}Using existing configuration from $CONFIG_FILE.${NC}"
fi

# Konfigurationsdatei einlesen (mit yq)
SYSTEM_NAME=$(yq '.system_name' $CONFIG_FILE)
SSH_PORT=$(yq '.ssh_port' $CONFIG_FILE)
LOG_LEVEL=$(yq '.log_level' $CONFIG_FILE)
DATA_DIR=$(yq '.data_dir' $CONFIG_FILE)

# Beispiel für die Verwendung der Variablen nach der Initialisierung
echo -e "${GREEN}System name: $SYSTEM_NAME${NC}"
echo -e "${GREEN}Running on Port: $SSH_PORT${NC}"
echo -e "${GREEN}Log Level: $LOG_LEVEL${NC}"
echo -e "${GREEN}Data Directory: $DATA_DIR${NC}"