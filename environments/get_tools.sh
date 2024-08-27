#!/bin/bash

# Farben für die Ausgabe
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # Keine Farbe

TOOLS_DIR="$1"   # Verzeichnis, in dem sich die Playbook-Skripte befinden
TOOLS="$2"       # Liste der ausgewählten Tools (z.B. docker, ansible, terraform)

echo -e "${GREEN}Tools directory is: $TOOLS_DIR${NC}"
echo -e "${GREEN}Selected tools are: $TOOLS${NC}"

# Ansible Playbook ausführen (nur wenn "ansible" im $TOOLS String vorkommt)
if [[ "$TOOLS" =~ "ansible" ]]; then
    echo -e "${GREEN}Running Ansible playbook...${NC}"
    
    # Überprüfen, ob das Playbook-Skript existiert
    if [ -f "$TOOLS_DIR/ansible/start_ansible_setup.sh" ]; then
        bash "$TOOLS_DIR/ansible/start_ansible_setup.sh"
        
        # Überprüfen, ob das Playbook erfolgreich ausgeführt wurde
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Ansible playbook executed successfully.${NC}"
        else
            echo -e "${RED}Ansible playbook execution failed.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Ansible playbook script not found: $TOOLS_DIR/ansible/start_ansible_setup.sh${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}Ansible is not listed in the TOOLS variable, skipping playbook execution.${NC}"
fi