#!/bin/bash

# Variablen definieren
username="$3"  # Ermittelt den username des Systems
opt_data_dir="$6"  # Verzeichnis, in dem die Datei abgelegt wird

output_file="${opt_data_dir}/NOT-SECURE-EXIT-${username}.yml"  # Dateiname mit username

vault_file="$4"
vault_secret="$5"

db_password="super_secret_password"
api_key="super_secret_api_key"
db_user="admin"
db_name="mydatabase"

# Überprüfen, ob das Verzeichnis existiert, falls nicht, wird es erstellt
if [ ! -d "$opt_data_dir" ]; then
    mkdir -p "$opt_data_dir"
fi

# Datei erstellen und Variablen mit Erklärungen schreiben
cat <<EOF > "$output_file"


# !!! IMPORTANT !!! RUNTIME ENVIRONMENT VARIABLES
# This file should not be on your system.
# This file contains the runtime environment variables for $username.
# Please copy the information to get access to the existing configurations of the system
# and delete this file afterwards.

vault_file: "$vault_file"
vault_secret: "$vault_secret"


EOF

# Erfolgsmeldung
echo "The file $output_file was successfully created."
