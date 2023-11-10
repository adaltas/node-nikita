#/bin/bash
set -e

# Logs: `ll /Library/Logs/Multipass`

# MacOS crash and image cant start:
# see https://github.com/canonical/multipass/issues/1924
# Restart multipass:
# sudo pkill multipassd
# multipass start nikita

brew list | grep -x "bash-completion" || brew install bash-completion
brew list | grep -x "multipass" || brew install --cask multipass

if multipass info nikita ; then
  multipass start nikita
  exit 0
fi

# Host creation
multipass launch \
  --name nikita \
  --cpus 8 \
  --memory 30G \
  --disk 100G

# Error: no DNS resolution
# Solution:
# In case you need a custom DNS
# multipass exec nikita -- sudo bash -c "echo 'DNS=8.8.8.8' >> /etc/systemd/resolved.conf"
# multipass exec nikita -- sudo systemctl restart systemd-resolved

# Error: `NikitaError: Error: Failed add validation for device "nikitadir": Missing source path "/Users/david/projects/github/nikita/" for disk "nikitadir"`
# Solution:
# Re-run `multipass mount $HOME nikita`

# LXD installation
multipass exec nikita -- sudo apt update
multipass exec nikita -- sudo apt upgrade -y
multipass exec nikita -- sudo snap refresh lxd --channel=latest/stable
multipass exec nikita -- sudo snap install multipass-sshfs
multipass mount $HOME nikita
multipass exec nikita -- sudo apt install -y zfsutils-linux
multipass exec nikita -- sudo truncate -s 100G /opt/zfs.img
multipass exec nikita -- sudo zpool create lxd /opt/zfs.img
multipass exec nikita -- lxd init --auto --storage-backend=zfs --storage-pool=lxd

# LXD configurqtion
multipass exec nikita -- lxc config set core.https_address '[::]:8443'
multipass exec nikita -- lxc config set core.trust_password "secret"
multipass exec nikita -- lxc config set images.remote_cache_expiry 30
multipass exec nikita -- lxc config set images.auto_update_interval 24
multipass exec nikita -- lxc config set images.auto_update_cached false
# Fix "ipa ERROR [Errno 13] Permission denied" 
multipass exec nikita -- sudo sh -c "echo 'fs.protected_regular = 0' >> /etc/sysctl.conf && sysctl -p"

IP=`multipass info nikita --format json | jq -r '.info.nikita.ipv4[0]'`
if lxc remote list --format json | jq -re .nikita; then
  lxc remote switch local
  lxc remote remove nikita
fi
lxc remote add nikita --accept-certificate --password secret $IP:8443
lxc remote switch nikita
