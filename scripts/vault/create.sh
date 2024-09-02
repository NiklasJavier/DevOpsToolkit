#!/bin/bash

# Farben für die Ausgabe
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # Keine Farbe

tools_dir="$1"      # Tools-Verzeichnis
config_file="$2"    # Konfigurationsdatei

ansibleName="host_vault_create" # Name des Ansible Playbooks -> playbookname bspw. (local_setup).yml
ansibleFolder="host"    # Ordner, in dem das Playbook liegt -> playbookfolder bspw. (local)

bash "$tools_dir/ansible/trigger_ansible_playbook.sh" "$tools_dir" "$config_file" "$ansibleName" "$ansibleFolder"