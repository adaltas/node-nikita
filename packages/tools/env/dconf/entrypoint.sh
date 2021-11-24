#!/bin/bash
set -e

service ssh start
dbus-launch

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
