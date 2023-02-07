#!/bin/bash

# Install LXD
if ! snap info lxd | grep "installed"; then
  sudo snap install lxd --channel=5.0/stable
fi
# Initialise LXD
sudo lxd waitready
sudo lxd init --auto
# Set up permissions for socket
sudo snap set lxd daemon.group=adm
sudo snap restart lxd
# Configure firewall
set -x
sudo iptables -I DOCKER-USER -j ACCEPT
