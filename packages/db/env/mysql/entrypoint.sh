#!/bin/bash

# Note, we had to disable the exit builtin because the until condition kill the
# script despite the documentation which state "the shell does not exit if the
# command that fails is part of the command list immediately following a while
# or until keyword"
# set -e

# Source Node.js
. ~/.bashrc
# Start ssh daemon
sudo /usr/sbin/sshd
# Wait until MySQL is ready
i=0; until echo > /dev/tcp/mysql/3306; do
   [[ i -eq 10 ]] && >&2 echo 'Docker not yet started after 10s' && exit 1
   ((i++))
   sleep 1
done
# Test execution
if test -t 0; then
  # We have TTY, so probably an interactive container...
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
