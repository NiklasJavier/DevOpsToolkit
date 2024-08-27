#!/bin/bash

# Farben für die Ausgabe
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # Keine Farbe

TOOLS_DIR="$1"      # Verzeichnis, in dem sich die Playbook-Skripte befinden
TOOLS="$2"          # Liste der ausgewählten Tools (z.B. docker, ansible, terraform)
SETTINGS_DIR="$3"   # Verzeichnis, das die config.yaml enthält

echo -e "${GREEN}Tools directory is: $TOOLS_DIR${NC}"
echo -e "${GREEN}Selected tools are: $TOOLS${NC}"
echo -e "${GREEN}Settings directory is: $SETTINGS_DIR${NC}"

# Überprüfen, ob das Settings-Verzeichnis existiert
if [ ! -d "$SETTINGS_DIR" ]; then
    echo -e "${RED}Error: Directory $SETTINGS_DIR does not exist.${NC}"
    exit 1
fi

# Ansible Playbook ausführen (nur wenn "ansible" im $TOOLS String vorkommt)
if [[ "$TOOLS" =~ "ansible" ]]; then
    echo -e "${GREEN}Running Ansible playbook...${NC}"

    ansible-playbook -i $TOOLS_DIR/ansible/local/hosts.ini $TOOLS_DIR/ansible/local/local_setup.yml --extra-vars "SETTINGS_DIR=$SETTINGS_DIR"
    
else
    echo -e "${GREEN}Ansible is not listed in the TOOLS variable, skipping playbook execution.${NC}"
fi