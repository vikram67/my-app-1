#!/usr/bin/env bash
set -e

function execute_ssh() {
    ssh -i /var/lib/jenkins/.ssh/id_rsa -o StrictHostKeyChecking=no root@3.17.189.247"$@";
}
# Specifing date & time for the delivery
BUILD_DATE=$(date +"%Y%m%d_%H%M")

tar -czvf kubyk_project.tar.gz app sqlite *.py *.txt# Create directory for all builds

execute_ssh mkdir -p /opt/kubykdev/# Copying the project to the DEV server

scp -i /var/lib/jenkins/.ssh/id_rsa -o StrictHostKeyChecking=no kubyk_project.tar.gz root@3.17.189.247:/opt/kubykdev# Creating directory and unpack our project

execute_ssh mkdir -p /opt/kubykdev/$BUILD_DATE
execute_ssh tar -xvf /opt/kubykdev/kubyk_project.tar.gz -C /opt/kubykdev/$BUILD_DATE
execute_ssh rm /opt/kubykdev/kubyk_project.tar.gz
execute_ssh "cd /opt/kubykdev/$BUILD_DATE && virtualenv venv && source venv/bin/activate && pip install -U pip setuptools wheel && pip install -U -r requirements.txt"
execute_ssh "chown -R www-data:www-data /opt/kubykdev/$BUILD_DATE";
execute_ssh "if [ -d /opt/kubyk ]; then rm /opt/kubyk; fi";
execute_ssh "ln -s /opt/kubykdev/$BUILD_DATE /opt/kubyk";# Restarting Ngixn & uWSGi
execute_ssh "systemctl restart uwsgi";
execute_ssh "systemctl restart nginx";
