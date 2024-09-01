#!/bin/bash

# Farben für die Ausgabe
GREEN='\033[0;32m'
GREY='\033[1;90m'
RED='\033[0;31m'
NC='\033[0m' # Keine Farbe

TOOLS_DIR="$1"
TOOLS="$2"

echo -e "${GREY}Tools directory is: $TOOLS_DIR${NC}"
echo -e "${GREY}Selected tools are: $TOOLS${NC}"

# Überprüfen, welche Tools ausgewählt wurden und die entsprechenden Installationsskripte ausführen

# Docker Installation
if [[ "$TOOLS" =~ "docker" ]]; then
    echo -e "${GREY}Installing Docker...${NC}"
    if [ -f "$TOOLS_DIR/docker/install_docker.sh" ]; then
        bash "$TOOLS_DIR/docker/install_docker.sh"
    else
        echo -e "${RED}Docker installation script not found: $TOOLS_DIR/docker/install_docker.sh${NC}"
    fi
fi

# Ansible Installation
if [[ "$TOOLS" =~ "ansible" ]]; then
    echo -e "${GREY}Installing Ansible...${NC}"
    if [ -f "$TOOLS_DIR/ansible/install_ansible.sh" ]; then
        bash "$TOOLS_DIR/ansible/install_ansible.sh"
    else
        echo -e "${RED}Ansible installation script not found: $TOOLS_DIR/ansible/install_ansible.sh${NC}"
    fi
fi