#!/bin/bash

# Farben für die Ausgabe
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m' 
BLUE='\033[0;34m' 
PINK='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # Keine Farbe

REPO_URL="https://github.com/NiklasJavier/DevOpsToolkit.git" # Name des Repositories
BRANCH="" # Variable zur Speicherung des Branch-Namens
BRANCH_DIR="" # Variable zur Speicherung des Branch-Verzeichnisses wird dynamisch festgelegt

FULL=false # Vollständige Installation (true) oder nicht (false)
USE_DEFAULTS=false # Möchten immer mit default werten arbeiten (true) oder nicht (false) Bspw. true wenn -t dev angegeben wurde
TOOLS="" # Liste der Tools, die installiert werden sollen

USERNAME="$(< /dev/urandom tr -dc 'A-Z' | head -c 11)" # Benutzername (zufällig generiert)
SYSTEM_NAME="SRV-$USERNAME" # Systemname (ehemals Hostname)
PORT="282" # Port für SSH-Verbindung
SSH_KEY_FUNCTION_ENABLED=false # SSH-Key-Funktion aktivieren
SSH_KEY_PUBLIC="none" # Öffentlicher SSH-Schlüssel

CLONE_DIR="/etc/DevOpsToolkit"
ENV_DIR="$CLONE_DIR/environments"
TOOLS_DIR="$CLONE_DIR/tools"
SCRIPTS_DIR="$CLONE_DIR/scripts" 
PIPELINES_DIR="$CLONE_DIR/pipelines" 

SETTINGS_DIR="" 
CONFIG_FILE="" # Konfigurationsdatei für das Setup in Settings-Verzeichnis
DEVOPS_CLI_FILE="$ENV_DIR/devops_cli.sh"

SYSLINK_PATH="/usr/sbin/devops" # Pfad für den Symlink
LOG_FILE="/var/log/devops_commands.log"

DEFAULT_TOOLS="ansible"
AVAILABLE_TOOLS="docker"

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

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -branch)
      shift
      case "$1" in
        production|staging|dev)
          USE_DEFAULTS=true # Immer mit Standardwerten arbeiten
          BRANCH="$1"
          ;;
        *)
          echo -e "${RED}Invalid branch specified with -t. Please use 'production', 'staging', or 'dev'.${NC}"
          exit 1
          ;;
      esac
      ;;
    -full) 
      shift
      if [[ "$1" == "true" || "$1" == "false" ]]; then
        FULL="$1"
      else
        echo -e "${RED}Invalid value for FULL. Please use 'true' or 'false'.${NC}"
        exit 1
      fi
      ;;
    -systemname) 
      shift
      if [[ -n "$1" && "$1" != -* ]]; then
        SYSTEM_NAME="$1"
      else
        echo -e "${RED}No systemname specified with -username.${NC}"
        exit 1
      fi
      ;;
    -key)
      shift
      SSH_KEY_FUNCTION_ENABLED=true  # SSH-Key-Funktion aktivieren
      if [[ -n "$1" && "$1" != -* ]]; then
        SSH_KEY_PUBLIC="$1"
      else
        SSH_KEY_FUNCTION_ENABLED=false
        SSH_KEY_PUBLIC=""  # Wenn leer, setze einen Standard-Schlüssel oder handle es entsprechend
      fi
      ;;
    -port)
      shift
      if [[ -n "$1" && "$1" != -* ]]; then
        PORT="$1"
      else
        echo -e "${RED}No port specified with -p.${NC}"
        exit 1
      fi
      ;;
    -tools)
      shift
      if [[ -n "$1" && "$1" != -* ]]; then
        TOOLS="$1 "
      else
        echo -e "${RED}No tools specified with -tools.${NC}"
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

BRANCH_DIR="$ENV_DIR/$BRANCH" # Branch-Verzeichnis festlegen
SETTINGS_DIR="$BRANCH_DIR/.settings" # Einstellungsverzeichnis festlegen
CONFIG_FILE="$SETTINGS_DIR/config.yaml" # Konfigurationsdatei festlegen

echo -e "${PINK}    ____            ____            ";
echo -e "${PINK}   / __ \___ _   __/ __ \____  _____";
echo -e "${PINK}  / / / / _ \ | / / / / / __ \/ ___/";
echo -e "${PINK} / /_/ /  __/ |/ / /_/ / /_/ (__  ) ";
echo -e "${PINK}/_____/\___/|___/\____/ .___/____/  ";
echo -e "${PINK}                     /_/            ";
echo -e "${PINK}                                    ";
echo -e "${PINK}                                    ";
echo -e "${PINK}--- parameter ---${NC}"
# Debugging-Ausgabe (kann entfernt werden) 
echo -e "${GREEN}Branch: $BRANCH ${NC}"
echo -e "${GREEN}Full HostSetup: $FULL ${NC}"
echo -e "${GREEN}Verwendete Tools: ${TOOLS[*]} ${NC}"
echo -e "${GREEN}Port: $PORT ${NC}"
echo -e "${GREEN}Benutzername: $USERNAME ${NC}"
echo -e "${GREEN}Systemname: $SYSTEM_NAME ${NC}"
echo -e "${GREEN}SSH Key aktiviert: $SSH_KEY_FUNCTION_ENABLED ${NC}"
echo -e "${GREEN}SSH Key Public: $SSH_KEY_PUBLIC ${NC}"
echo -e "${GREEN}Branch-Verzeichnis: $BRANCH_DIR ${NC}"
echo -e "${GREEN}Einstellungsverzeichnis: $SETTINGS_DIR ${NC}"
echo -e "${GREEN}Konfigurationsdatei: $CONFIG_FILE ${NC}"
echo -e "${GREEN}Skriptverzeichnis: $SCRIPTS_DIR ${NC}"
echo -e "${GREEN}Pipeline-Verzeichnis: $PIPELINES_DIR ${NC}"

# Überprüfen, ob das Skript als Root ausgeführt wird
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root.${NC}"
    exit 1
fi

echo -e "${PINK}--- copy of the git repository ---${NC}"
# Überprüfen, ob Git installiert ist
if ! command -v git &> /dev/null; then
    echo -e "${RED}Git is not installed. Installing Git...${NC}"
    echo -e "${GREEN}"
    sudo apt-get update
    sudo apt-get install -y git
    echo -e "${NC}"

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
    echo -e "${YELLOW}"
    sudo git clone -b "$BRANCH" --single-branch "$REPO_URL" "$CLONE_DIR"
    echo -e "${NC}"
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to clone the repository. Aborting...${NC}"
        exit 1
    fi
fi

# Prüfen, ob der branch-spezifische Ordner existiert, und erstellen, wenn nicht

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

echo -e "${PINK}--- create the config.yml ---${NC}" # Config anlegen
touch -f "$SETTINGS_DIR/config.yaml"

echo -e "${PINK}--- change the cli-wrapper confline ---${NC}"
# Konfigurationsdatei für das Setup in devops_cli.sh einfügen
CLI_CONFIG_MODLINE="CONFIG_FILE="
CLI_CONFIG_MODLINE+="\"$CONFIG_FILE\""
sed -i "5i $CLI_CONFIG_MODLINE" "$DEVOPS_CLI_FILE"
echo -e "${GREEN}Zeile wurde in $DEVOPS_CLI_FILE an Position 5 eingefügt.${NC}"

echo -e "${PINK}--- create cli-wrapper sbin link ---${NC}"
# Überprüfen, ob der Symlink bereits existiert
if [ -L "$SYSLINK_PATH" ]; then
    # Wenn der Symlink existiert, überprüfen, ob er auf die richtige Datei zeigt
    if [ "$(readlink "$SYSLINK_PATH")" != "$DEVOPS_CLI_FILE" ]; then
        echo -e "${GREEN}Symlink $SYSLINK_PATH existiert und zeigt auf einen anderen Pfad. Aktualisierung...${NC}"
        sudo ln -sf "$DEVOPS_CLI_FILE" "$SYSLINK_PATH"
    else
        echo -e "${GREEN}Symlink $SYSLINK_PATH existiert bereits und zeigt auf das richtige Ziel.${NC}"
    fi
else
    # Wenn der Symlink nicht existiert, erstelle ihn
    echo -e "${GREEN}Symlink $SYSLINK_PATH existiert nicht. Erstellen...${NC}"
    sudo ln -s "$DEVOPS_CLI_FILE" "$SYSLINK_PATH"
fi


# Alle Skripte ausführbar machen
echo -e "${GREEN}Making all scripts in $CLONE_DIR executable...${NC}"
sudo find "$CLONE_DIR" -type f -name "*.sh" -exec chmod +x {} \;

echo -e "${GREEN}Setup completed! Repository cloned to $CLONE_DIR and scripts are now executable.${NC}"

echo -e "${PINK}--- adjusting the parameters ---${NC}"

# System Name festlegen (ehemals Hostname)
if [ -z "$SYSTEM_NAME" ]; then
    default_system_name="$SYSTEM_NAME"
    if [ "$USE_DEFAULTS" = true ]; then
        SYSTEM_NAME="$default_system_name"
    else
        read -r -p "Enter system name (default: $default_system_name): " SYSTEM_NAME < /dev/tty
        SYSTEM_NAME=${SYSTEM_NAME:-"$default_system_name"}
    fi
    echo -e "${GREEN}SYSTEM_NAME set to: $SYSTEM_NAME${NC}"
fi

# SSH_PORT festlegen
if [ -z "$SSH_PORT" ]; then
    default_ssh_port="282"
    if [ "$USE_DEFAULTS" = true ]; then
        SSH_PORT="$default_ssh_port"
    else
        read -r -p "Enter the SSH_PORT (default: $default_ssh_port): " SSH_PORT < /dev/tty
        SSH_PORT=${SSH_PORT:-"$default_ssh_port"}
    fi
    echo -e "${GREEN}SSH_PORT set to: $SSH_PORT${NC}"
fi

# Log Level festlegen
if [ -z "$LOG_LEVEL" ]; then
    default_log_level="info"
    if [ "$USE_DEFAULTS" = true ]; then
        LOG_LEVEL="$default_log_level"
    else
        read -r -p "Enter the log level (default: $default_log_level) [debug, info, warn, error]: " LOG_LEVEL < /dev/tty
        LOG_LEVEL=${LOG_LEVEL:-"$default_log_level"}
    fi
    echo -e "${GREEN}LOG_LEVEL set to: $LOG_LEVEL${NC}"
fi

# OPT Datenverzeichnis festlegen, das auf dem Systemnamen basiert
if [ -z "$OPT_DATA_DIR" ]; then
    default_opt_data_dir="/opt/$SYSTEM_NAME/data"
    if [ "$USE_DEFAULTS" = true ]; then
        OPT_DATA_DIR="$default_opt_data_dir"
    else
        read -r -p "Enter the opt data directory (default: $default_opt_data_dir): " OPT_DATA_DIR < /dev/tty
        OPT_DATA_DIR=${OPT_DATA_DIR:-"$default_opt_data_dir"}
    fi
    echo -e "${GREEN}OPT_DATA_DIR set to: $OPT_DATA_DIR${NC}"
fi

# Benutzerauswahl der Tools
if [ "$USE_DEFAULTS" = true ]; then
    TOOLS+="$DEFAULT_TOOLS"
else
    read -r -p "Which tools do you want to install? (default: $AVAILABLE_TOOLS): " selected_tools < /dev/tty
    TOOLS=${TOOLS:-$AVAILABLE_TOOLS}
fi

# Konfiguration in config.yaml speichern
echo -e "${PINK}--- saving the configuration ---${NC}"
echo -e "${GREEN}To $CONFIG_FILE...${NC}"

# Speichern der Konfiguration
cat <<- EOL > "$CONFIG_FILE"
# system_name: Der Name des Systems oder Servers, der für die Konfiguration verwendet wird.
# Wenn der Benutzer keinen Namen eingibt, wird ein Standardname generiert.
system_name: "$SYSTEM_NAME"

# ssh_port: Der SSH-Port, über den die Verbindung zum Server hergestellt wird.
# Standardmäßig wird Port 282 verwendet, falls der Benutzer keinen Port angibt.
ssh_port: "$SSH_PORT"

# log_level: Das gewünschte Log-Level für die Protokollierung der Anwendung.
# Mögliche Optionen sind "debug", "info", "warn" und "error".
# Wenn der Benutzer keinen Wert angibt, wird "info" verwendet.
log_level: "$LOG_LEVEL"

# opt: Das Datenverzeichnis, in dem Anwendungsdaten gespeichert werden.
# Dieses Verzeichnis basiert standardmäßig auf dem system_name (z.B. /opt/$SYSTEM_NAME/data),
# falls der Benutzer kein anderes Verzeichnis angibt.
opt_data_dir: "$OPT_DATA_DIR"

# use_defaults: Eine Flag-Variable, die angibt, ob das Skript im "Default-Modus" ausgeführt wird.
# Wenn use_defaults auf "true" gesetzt ist, werden keine Eingabeaufforderungen an den Benutzer gestellt.
# Stattdessen werden automatisch die Standardwerte verwendet.
use_defaults: "$USE_DEFAULTS"

# TOOLS: Diese Variable enthält die Liste der Tools, die installiert werden sollen.
# Der Benutzer kann die Tools manuell eingeben (z.B. docker ansible terraform) oder, 
# falls keine Eingabe erfolgt, wird der Standardwert verwendet, der alle Tools umfasst.
# Wenn die Option USE_DEFAULTS=true gesetzt ist, werden automatisch alle Standardtools
# ausgewählt, ohne eine Benutzereingabe zu erfordern.
tools: "$TOOLS"

# SSH_KEY_FUNCTION_ENABLED: Diese Variable gibt an, ob die SSH-Key-Funktion aktiviert ist.
# Sie wird auf "false" gesetzt, wenn kein SSH-Key angegeben wird oder die Funktion
# standardmäßig deaktiviert ist. Wenn ein gültiger SSH-Schlüssel eingegeben wird,
# wird sie auf "true" gesetzt und die SSH-Key-Funktion wird aktiviert.
ssh_key_function_enabled: "$SSH_KEY_FUNCTION_ENABLED"

# SSH_KEY_PUBLIC: Diese Variable enthält den öffentlichen SSH-Schlüssel (Public Key),
# den der Benutzer eingegeben hat. Wenn kein Schlüssel eingegeben wird, bleibt diese
# Variable leer (""). Wenn ein gültiger SSH-Schlüssel eingegeben wird, wird dieser hier gespeichert.
ssh_key_public: "$SSH_KEY_PUBLIC"

# tools_dir: Speichert den Pfad zu dem Verzeichnis, in dem verschiedene Tools (z.B. Ansible, Docker, Terraform)
# abgelegt sind. Dies ist der Ort, an dem alle Tool-spezifischen Dateien oder Konfigurationen gespeichert werden.
tools_dir: "$TOOLS_DIR"

# scripts_dir: Speichert den Pfad zu dem Verzeichnis, in dem allgemeine Skripte abgelegt sind.
# Hier befinden sich Automatisierungsskripte oder Hilfsskripte, die für verschiedene Aufgaben oder Prozesse genutzt werden.
scripts_dir: "$SCRIPTS_DIR"

# pipelines_dir: Speichert den Pfad zu dem Verzeichnis, in dem Pipeline-Konfigurationsdateien (z.B. CI/CD-Pipelines) gespeichert sind.
# Dieses Verzeichnis enthält die Dateien für Jenkins, GitLab CI oder andere CI/CD-Tools, die in Automatisierungsprozesse integriert sind.
pipelines_dir: "$PIPELINES_DIR"

username: "$USERNAME"

log_file: "$LOG_FILE"

systemlink_path: "$SYSLINK_PATH"

EOL
echo -e "${GREEN}Configuration saved in $CONFIG_FILE.${NC}"


echo -e "${PINK}--- installation of the tools ---${NC}"
# Überprüfen, ob install_tools.sh existiert und ausführen
if [ -f "$CLONE_DIR/environments/install_tools.sh" ]; then
    echo -e "${GREEN}Switching to $CLONE_DIR/environments/install_tools.sh${NC}"
    bash "$CLONE_DIR/environments/install_tools.sh" "$TOOLS_DIR" "$TOOLS"
    
    # Weiter im Skript, nachdem install_tools.sh ausgeführt wurde
    echo -e "${GREEN}Returned from install_tools.sh, continuing...${NC}"
else
    echo -e "${RED}Error: $CLONE_DIR/environments/install_tools.sh not found!${NC}"
    exit 1
fi

# Überprüfen, ob die Variable FULL auf true gesetzt ist
if [ "$FULL" = true ]; then
    # Ausgabe einer Nachricht
    echo -e "${PINK}--- setting up the host ---${NC}"
    # Überprüfen, ob das Skript run_ansible_setup.sh existiert und es ausführen
    if [ -f "$CLONE_DIR/environments/run_ansible_setup.sh" ]; then
        echo -e "${GREEN}Switching to $CLONE_DIR/environments/run_ansible_setup.sh${NC}"
        exec bash "$CLONE_DIR/environments/run_ansible_setup.sh" "$TOOLS_DIR" "$TOOLS" "$SETTINGS_DIR"
    else
        echo -e "${RED}Error: $CLONE_DIR/environments/run_ansible_setup.sh not found!${NC}"
        exit 1
    fi
fi
