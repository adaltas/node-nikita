#!/bin/bash
set -e

# Source Node.js
. ~/.bashrc
# Start ssh daemon
/usr/sbin/sshd
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
else
  npm run test:local
fi
