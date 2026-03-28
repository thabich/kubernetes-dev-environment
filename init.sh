#!/bin/bash

# Install Vagrant and create venv for Ansible
# Support WSL based installations
#
# Version 0.1
#
# ToDos:
# 1. proper error handling
# 2. support RHEL based systems
# 3. more flexibility
#


deb_install_vagrant() {
	curl -s https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        sudo apt update && sudo apt install -y vagrant
}

write_status() {
  echo -e "\n\n######\n#\n# $1\n#\n######\n"
}

# Detect WSL
if uname -r | grep WSL > /dev/null ; then 
        write_status "Working in WSL... fine..."
	WSL=1
else
	WLS=0
fi

if grep -i debian /etc/os-release > /dev/null; then
        write_status "Debian family found using apt"
	sudo apt update
	sudo apt install -y curl python3 python3-venv python3-pip crudini
        deb_install_vagrant
	PYTHON=python3
else
	write_status "Currently only Debian based systems are supported"
fi

write_status "Initializing venv"
$PYTHON -m venv venv
source venv/bin/activate
$PYTHON -m pip install -U pip
$PYTHON -m pip install -U -r requirements.txt

if [ $WSL == 1 ]; then
	write_status "Installing WSL plugin..."
	vagrant plugin install virtualbox_WSL2
        write_status "Modifying automount options in /etc/wsl.conf"
	sudo crudini --set /etc/wsl.conf  automount options "metadata,umask=22,fmask=11"
        sudo crudini --set /etc/wsl.conf  automount enabled true
	EXPORTS='export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1" VAGRANT_WSL_WINDOWS_ACCESS_USER_HOME_PATH="/mnt/c/checkouts/"'
	write_status "Please add the following to your .bashc\n# $EXPORTS"
	$EXPORTS

        write_status "You will have to restart WSL after the installation ( wsl --shutdown distroName and wsl -d distroName in PowerShell)" 
fi

write_status "Installation finished, please make sure to run source venv/bin/activate each time before using vagrant"
