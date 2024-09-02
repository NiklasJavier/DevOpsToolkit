#!/bin/bash

devops debug exit-cleanup 

# Farben für die Ausgabe
echo "DEBUG: Cleanup"


if [ -d ~/.curl ]; then
    rm -rf ~/.curl
else
    echo "Der Pfad ~/.curl existiert nicht."
fi

if [ -d /etc/DevOpsToolkit ]; then
    rm -r /etc/DevOpsToolkit
else
    echo "Der Pfad /etc/DevOpsToolkit existiert nicht."
fi

curl -fsSL https://raw.githubusercontent.com/NiklasJavier/DevOpsToolkit/dev/environments/setup_devops_toolkit.sh | bash -s -- -branch dev