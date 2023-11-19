#!/bin/bash
set -e

# Source Node.js
. ~/.bashrc
# We have TTY, so probably an interactive container...
if test -t 0; then
  if [[ $@ ]]; then
    # Transfer arguments to mocha
    node_modules/.bin/mocha $@
  else
    # Run bash when no argument
    export PS1='[\u@\h : \w]\$ '
    /bin/bash
  fi
# Detached mode
else
  npm run test:local
fi
