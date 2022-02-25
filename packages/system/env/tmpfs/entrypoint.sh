#!/bin/bash
set -e

# Start ssh daemon
sudo /usr/sbin/sshd
# We have TTY, so probably an interactive container...
if test -t 0; then
  # Some command(s) has been passed to container? Execute them and exit.
  if [[ $@ ]]; then
    npx mocha $@
  # No commands provided? Run bash.
  else
    # Run bash when no argument
    export PS1='[\u@\h : \w]\$ '
    /bin/bash
  fi
else
  # Detached mode
  npm run test:local
fi
