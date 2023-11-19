#!/bin/bash
set -e

# kadmin -r NODE.DC1.CONSUL -p admin/admin -s krb5 -w admin -q 'listprincs'
until echo admin | kinit admin/admin
do
  echo 'waiting for kinit to succeed'
  sleep 2
done

# Source Node.js
. ~/.bashrc
# Start ssh daemon
sudo /usr/sbin/sshd
# We have TTY, so probably an interactive container...
if test -t 0; then
  # Some command(s) has been passed to container? Execute them and exit.
  # No commands provided? Run bash.
  if [[ $@ ]]; then
    node_modules/.bin/mocha $@
  else
    export PS1='[\u@\h : \w]\$ '
    /bin/bash
  fi
# Detached mode
else
  npm run test:local
fi
