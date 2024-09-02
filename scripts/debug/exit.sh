#!/bin/bash

devops debug save-exit-runtime-vars

if [ -d /etc/DevOpsToolkit ]; then
    rm -r /etc/DevOpsToolkit
else
    echo "Der Pfad /etc/DevOpsToolkit existiert nicht."
fi

if [ -d /usr/sbin/devops ]; then
    rm -r /usr/sbin/devops
else
    echo "Der Pfad /usr/sbin/devops existiert nicht."
fi

if [ -d /var/log/devops_commands.log ]; then
    rm -r /var/log/devops_commands.log
else
    echo "Der Pfad /var/log/devops_commands.log existiert nicht."
fi

if [ -d /var/log/devops_commands.log ]; then
    rm -r /var/log/devops_commands.log
else
    echo "Der Pfad /var/log/devops_commands.log existiert nicht."
fi