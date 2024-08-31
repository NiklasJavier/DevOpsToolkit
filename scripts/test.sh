#!/bin/bash

# Alle Variablen aus der temporären Datei einlesen
source /tmp/devops-cli-vars.tmp

echo "test funktioniert"
echo "var test"
echo "SSH-KEY: $ssh_key_public"

# Löschen der temporären Datei nach Gebrauch
rm /tmp/devops-cli-vars.tmp