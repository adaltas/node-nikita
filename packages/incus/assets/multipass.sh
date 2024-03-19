#/bin/bash
set -e



help(){
  echo """
Usage:
  ./multipass.sh <command>

Available Commands:
  install
  reload
  help

"""
}

install(){
  # Logs: `ll /Library/Logs/Multipass`
  brew list | grep -x "bash-completion" || brew install bash-completion
  brew list | grep -x "multipass" || brew install --cask multipass
  brew list | grep -x "incus" || brew install incus
  if multipass info nikita ; then
    multipass start nikita
  else
    # Host creation
    multipass launch \
      --name nikita \
      --cpus 8 \
      --memory 30G \
      --disk 100G
  fi
  # Fix DNS
  multipass exec nikita -- sudo bash -c "echo 'DNS=8.8.8.8' >> /etc/systemd/resolved.conf"
  multipass exec nikita -- sudo systemctl restart systemd-resolved
  # OS preparation installation
  multipass exec nikita -- sudo apt update
  multipass exec nikita -- sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y
  multipass exec nikita -- sudo sh -c "echo 'fs.protected_regular = 0' >> /etc/sysctl.conf && sysctl -p"
  # File mount
  multipass exec nikita -- sudo snap install multipass-sshfs
  # Only pass the target machine name, if the mount point is omitted,
  # it is the same as the source's absolute path
  if ! multipass info nikita --format json | jq -re '.info.nikita.mounts."/Users/david"'; then
    multipass mount $HOME nikita
  fi
  # Incus installation
  multipass exec nikita -- curl -fsSL https://pkgs.zabbly.com/key.asc | gpg --show-keys --fingerprint
  multipass exec nikita -- sudo mkdir -p /etc/apt/keyrings/
  multipass exec nikita -- sudo curl -fsSL https://pkgs.zabbly.com/key.asc -o /etc/apt/keyrings/zabbly.asc
  multipass exec nikita -- sudo sh -c 'cat <<EOF > /etc/apt/sources.list.d/zabbly-incus-stable.sources
Enabled: yes
Types: deb
URIs: https://pkgs.zabbly.com/incus/stable
Suites: $(. /etc/os-release && echo ${VERSION_CODENAME})
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/zabbly.asc

EOF'
  multipass exec nikita -- sudo apt update
  multipass exec nikita -- sudo DEBIAN_FRONTEND=noninteractive apt install -y incus
  multipass exec nikita -- sudo DEBIAN_FRONTEND=noninteractive apt install -y zfsutils-linux
  multipass exec nikita -- sudo truncate -s 100G /opt/zfs.img
  multipass exec nikita -- sudo zpool create incus /opt/zfs.img
  # Initialisation
  multipass exec nikita -- sudo sh -c 'cat <<EOF | incus admin init --preseed
# Daemon settings
config:
  core.https_address: "[::]:8443"
  images.remote_cache_expiry: 30
  images.auto_update_interval: 24
  images.auto_update_cached: false
# Storage pools
storage_pools:
- name: data
  driver: zfs
  config:
    source: incus
# Network devices
networks:
- name: incusbr0
  type: bridge
  config:
    ipv4.address: auto
    ipv6.address: none
# Profiles
profiles:
- name: default
  devices:
    root:
      path: /
      pool: data
      type: disk
    eth0:
      name: eth0
      nictype: bridged
      parent: incusbr0
      type: nic
EOF'
  reload
}

reload(){
  if incus remote list --format json | jq -re .nikita; then
    incus remote switch local
    incus remote remove nikita
  fi
  certificate=`multipass exec nikita -- sudo incus config trust add nikita --quiet`
  incus remote add nikita $certificate
  incus remote switch nikita
}

info(){
  multipass_ip=`multipass info nikita --format json | jq -r '.info.nikita.ipv4[0]'`
  incus_active=`multipass exec nikita -- sudo systemctl is-active --quiet incus && echo true || echo false`
  echo "Multipass IP: $multipass_ip"
  echo "Incus service active: $active"
}

remove(){
  multipass delete nikita
  multipass purge
}

notes(){
  echo """
Info: get machine IP
IP=`multipass info nikita --format json | jq -r '.info.nikita.ipv4[0]'`
echo $IP

Error: Failed to create certificate: Client is already trusted
The server has already registered a client with the same name, all its certficate must be revoked and the client must then be removed
Solution:
multipass exec nikita -- sudo incus config trust list-tokens
multipass exec nikita -- sudo incus config trust revoke-token nikita
multipass exec nikita -- sudo incus config trust remove nikita

Error: no DNS resolution
Solution:
In case you need a custom DNS
multipass exec nikita -- sudo bash -c "echo 'DNS=8.8.8.8' >> /etc/systemd/resolved.conf"
multipass exec nikita -- sudo systemctl restart systemd-resolved

Error: `NikitaError: Error: Failed add validation for device "nikitadir": Missing source path "/Users/david/projects/github/nikita/" for disk "nikitadir"`
Solution:
Re-run `multipass mount $HOME nikita`

Multipass does not respond
Solution:
restart multipass
sudo launchctl stop com.canonical.multipassd
sudo launchctl start com.canonical.multipassd

MacOS crash and image cant start:
see https://github.com/canonical/multipass/issues/1924
Force kill multipass, it shall restart:
sudo pkill multipassd
multipass start nikita
"""
}

case "$1" in
  remove) remove
    ;;
  install) install
    ;;
  reload) reload
    ;;
  info) info
    ;;
  *) help
    ;;
esac
