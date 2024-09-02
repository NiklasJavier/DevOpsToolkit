#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m' 
BLUE='\033[0;34m' 
PINK='\033[0;35m'
BOLD='\033[1m'
GREY='\033[1;90m'
NC='\033[0m' 

issueReturnRequestToWork() {
    echo -e "${RED}⚠️  WARNING: This script will delete all ports not listed in the SSH configuration and all folders not present in the config.yml file.${NC}"
    echo -e "${RED}Please ensure the current directory is listed in the config.yml file, or these files will be permanently deleted.${NC}"
    
    read -p "Do you wish to proceed? (yes/no): " confirmation
    
    if [[ "$confirmation" != "yes" ]]; then
        echo "${RED}Operation aborted. No changes were made.${NC}"
        exit 1
    fi
}

findAndDeleteOldUsers(){
find /home -regextype posix-extended -maxdepth 1 -mindepth 1 -type d -regex '.*/[A-Z]{11}' | while read -r dir; do
  username=$(basename "$dir")
  echo -e "${GREY}Extracted user name: ${YELLOW}$username${NC}"
  # Add the user name to the list if it is not the currentUsername
  if [ "$username" != "$currentUsername" ]; then
    user_list+=("$username")
    echo "$username wird gelöscht"
    srv_dir="/opt/SRV-$username"
    home_dir="/home/$username"
    sudo userdel -r "$username"
    sudo rm -rf "$srv_dir"
    sudo rm -rf "$home_dir"
  else
    echo -e "${RED}The user ${YELLOW}$username ${RED}is the current user and will not be deleted.${NC}"
  fi
done
}

checkSSHPortAndCleanUFWRules(){
# Step 1: Extract the SSH port from the configuration file
ssh_port=$(grep "^Port " /etc/ssh/sshd_config | awk '{print $2}')
# If no port is explicitly set in the file, use default port 22
if [ -z "$ssh_port" ]; then
  ssh_port=22
fi
echo -e "${GREY}Extracted SSH port: ${YELLOW}$ssh_port${NC}"
# Step 2: List of open ports with ufw
open_ports=$(sudo ufw status numbered | grep -oP '\d+(?=/tcp)')
# Step 3: Remove rules for unused ports
for port in $open_ports; do
  if [ "$port" -ne "$ssh_port" ]; then
    echo -e "${RED}Port ${YELLOW}$port ${RED}is not the SSH port and will be deleted.${NC}"
    sudo ufw delete allow "$port/tcp"
  fi
done
}

methods=(
issueReturnRequestToWork
findAndDeleteOldUsers
checkSSHPortAndCleanUFWRules
)

for method in "${methods[@]}"; do
echo -e "\n${GREY}======= ${GREEN}Running: ${PINK}[$method] ${GREY}=======${NC}"
$method 
done
