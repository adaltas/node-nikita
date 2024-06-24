#!/usr/bin/env bash
set -e

cd `pwd`/`dirname ${BASH_SOURCE}`

function build {
  # Create new machine
  multipass launch \
    --name nikita-system-cgroup \
    --cpus 2 \
    --memory 10G \
    --disk 20G \
    release:20.04
  NIKITA_HOME=`node -e "process.stdout.write(path.join(process.cwd(), '../../../..'))"`
  # Fix DNS
  multipass exec nikita-system-cgroup -- bash <<EOF
sudo su -
bash -c "echo 'DNS=8.8.8.8' >> /etc/systemd/resolved.conf"
systemctl restart systemd-resolved
EOF
  # Allow mounting directories
  multipass exec nikita-system-cgroup -- sudo apt upgrade -y
  multipass exec nikita-system-cgroup -- sudo snap install multipass-sshfs
  multipass mount $NIKITA_HOME nikita-system-cgroup:/nikita
  # Install Node.js
  multipass exec nikita-system-cgroup bash <<'EOF'
if command -v node ; then exit 42; fi
curl -sS -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
# NVM is sourced from ~/.bashrc which is not loaded in non interactive mode
echo '. $HOME/.nvm/nvm.sh' >> $HOME/.profile
. $HOME/.profile
nvm install 22
EOF
  # Configure SSH
  multipass exec nikita-system-cgroup bash <<'EOF'
mkdir -p $HOME/.ssh && chmod 700 $HOME/.ssh
if [ ! -f $HOME/.ssh/id_ed25519 ]; then
ssh-keygen -t ed25519 -f $HOME/.ssh/id_ed25519 -N ''
cat $HOME/.ssh/id_ed25519.pub >> $HOME/.ssh/authorized_keys
# sudo bash -c "cat $HOME/.ssh/id_ed25519.pub >> /root/.ssh/authorized_keys"
fi
EOF
  # Install test dependencies
  multipass exec nikita-system-cgroup bash <<EOF
sudo su -
apt update -y && apt install -y cgroup-tools
cp -pr /usr/share/doc/cgroup-tools/examples/cgsnapshot_blacklist.conf /etc/cgsnapshot_blacklist.conf
EOF
}

if multipass info nikita-system-cgroup ; then
  multipass start nikita-system-cgroup
else
  build
fi

# Run tests
multipass exec nikita-system-cgroup bash <<'EOF'
. $HOME/.profile
export NIKITA_TEST_MODULE=/nikita/packages/system/env/cgroups-multipass/test.coffee
cd /nikita/packages/system/
npm run test:local
EOF
# Enter the container
# multipass exec nikita-system-cgroup -d /nikita/packages/system/ -- bash
