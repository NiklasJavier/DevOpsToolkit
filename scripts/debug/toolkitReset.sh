#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m' 
BLUE='\033[0;34m' 
PINK='\033[0;35m'
BOLD='\033[1m'
GREY='\033[1;90m'
NC='\033[0m' # Keine Farbe

config_file="$2"

loadParametersFromSettings(){
while IFS= read -r line
do
    # Nur Zeilen verarbeiten, die ein ":" enthalten
    if echo "$line" | grep -q ":"; then
        # Den Namen und den Wert extrahieren
        var_name=$(echo "$line" | cut -d ':' -f 1 | xargs | tr ' ' '_')
        var_value=$(echo "$line" | cut -d ':' -f 2- | xargs)
        # Entferne die Anführungszeichen, wenn sie vorhanden sind
        var_value=$(echo "$var_value" | sed 's/^"\(.*\)"$/\1/')
        # Die Variable setzen
        eval "$var_name=\"$var_value\""
    fi
done < "$config_file"
echo -e "${GREY}The configuration file ${YELLOW}$config_file ${GREY}was successfully loaded.${NC}"
}

# Variablen definieren
output_file="${opt_data_dir}/devopsVaultAccessSecret-${username}.yml"  # Dateiname mit username
vault_startup="${opt_data_dir}/openVault.sh"  # Pfad zur zu erstellenden .sh-Datei

checkIfVaultFolderExists() {
if [ ! -d "$opt_data_dir" ]; then
    mkdir -p "$opt_data_dir"
    else
    echo -e "${GREY}The directory ${YELLOW}$opt_data_dir ${GREY}already exists.${NC}"
fi
}

writeEnvironmentVariablesInBackupFile(){
cat <<EOF > "$output_file"
# !!! IMPORTANT !!! RUNTIME ENVIRONMENT VARIABLES
# This file is temporary and should not remain on your system.
# It contains sensitive runtime environment variables for $username.
# Please copy the necessary information to access the system's configurations,
# and securely delete this file immediately afterward.

vault_file: "$vault_file"
vault_secret: "$vault_secret"
EOF
echo -e "${GREY}The file ${YELLOW}$output_file ${GREY}was successfully created.${NC}"
}

writeExecutionScriptForVaultAccess(){
cat <<EOF > "$vault_startup"
#!/bin/bash
# This script opens the Vault file vault.yml with ansible-vault.
RED='\033[0;31m'
NC='\033[0m'
YELLOW='\033[1;33m'

if [ -f "$output_file" ]; then
  echo "${RED}"
  cat "$output_file"
  echo "${NC}"
fi

if [ ! -f "$vault_file" ]; then
  echo -e "${RED}The file ${YELLOW}"$vault_file" ${RED}was not found.${GREY}"
  exit 1
fi

ansible-vault view "$vault_file"
EOF
chmod +x "$vault_startup"
echo -e "${GREY}The script ${YELLOW}$vault_startup ${GREY}was successfully created.${NC}"
}

deleteDevopsToolkitRepository(){
if [ -d $clone_dir ]; then
    rm -r $clone_dir
else
    echo -e "${GREY}The directory ${YELLOW}$clone_dir ${GREY}does not exist.${NC}"
fi
}

methods=(
loadParametersFromSettings
checkIfVaultFolderExists
writeEnvironmentVariablesInBackupFile
writeExecutionScriptForVaultAccess
deleteDevopsToolkitRepository
)

for method in "${methods[@]}"; do
echo -e "\n${GREY}======= ${GREEN}Running: ${PINK}[$method] ${GREY}=======${NC}"
$method 
done
