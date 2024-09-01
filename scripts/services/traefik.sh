#!/bin/bash

# Farben für die Ausgabe
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # Keine Farbe

tools_dir="$1"      # Tools-Verzeichnis
config_file="$2"

# Variablen für Ansible
ansibleName="local_setup" # Name des Ansible Playbooks -> playbookname bspw. (local_setup).yml
ansibleFolder="local"    # Ordner, in dem das Playbook liegt -> playbookfolder bspw. (local)

start_playbook() {
    local playbookname=$1
    local playbookfolder=$2
    echo -e "${GREEN}Running Ansible ${playbookfolder}/${playbookname}...${NC}"
    ANSIBLE_CONFIG=$tools_dir/ansible/${playbookfolder}/ansible.cfg ansible-playbook -i $tools_dir/ansible/${playbookfolder}/hosts.ini $tools_dir/ansible/${playbookfolder}/playbooks/${playbookname} --extra-vars "CONFIG_YAML=$config_file"
}

# Überprüfen, ob Docker installiert ist
if ! command -v docker &> /dev/null
then
    echo -e "${RED}Docker ist nicht installiert. Führe Installationsskript aus...${NC}"
    bash "$tools_dir/docker/install_docker.sh"
    start_playbook "$ansibleName.yml" "$ansibleFolder"
else
    echo -e "${GREEN}Docker ist bereits installiert.${NC}"
    start_playbook "$ansibleName.yml" "$ansibleFolder"
fi