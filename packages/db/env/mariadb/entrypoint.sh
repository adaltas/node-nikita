#!/bin/bash
set -e

# Source Node.js
. ~/.bashrc
# Start ssh daemon
sudo /usr/sbin/sshd
if test -t 0; then
  # We have TTY, so probably an interactive container...
  if [[ $@ ]]; then
    # Transfer arguments to mocha
    . ~/.bashrc
    npx mocha $@
  else
    export PS1='[\u@\h : \w]\$ '
    /bin/bash
  fi
# Detached mode
else
  npm run test:local
fi
