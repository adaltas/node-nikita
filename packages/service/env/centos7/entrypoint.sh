#!/bin/bash
set -e

# We have TTY, so probably an interactive container...
if test -t 0; then
  # Run supervisord detached...
  supervisord -c /etc/supervisord.conf
  # Some command(s) has been passed to container? Execute them and exit.
  # No commands provided? Run bash.
  if [[ $@ ]]; then 
    npx mocha $@
  else
    export PS1='[\u@\h : \w]\$ '
    /bin/bash
  fi
# Detached mode
else
  # Run supervisord in foreground, which will stay until container is stopped.
  supervisord -c /etc/supervisord.conf
  npm run test:local
fi
