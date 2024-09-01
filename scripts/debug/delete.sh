#!/bin/bash

if [ -d /etc/DevOpsToolkit ]; then
    rm -r /etc/DevOpsToolkit
else
    echo "Der Pfad /etc/DevOpsToolkit existiert nicht."
fi