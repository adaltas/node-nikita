#!/bin/bash

# Note, we had to disable the exit builtin because the until condition kill the
# script despite the documentation which state "the shell does not exit if the
# command that fails is part of the command list immediately following a while
# or until keyword"
# set -e

# Start ssh daemon
sudo /usr/sbin/sshd
# Wait until Docker is ready
i=0; until echo > /dev/tcp/dind/2375; do
   [[ i -eq 20 ]] && >&2 echo 'Docker not yet started after 20s' && exit 1
   ((i++))
   sleep 1
done
# Test execution
if test -t 0; then
  # We have TTY, so probably an interactive container...
  if [[ $@ ]]; then
    # Transfer arguments to mocha
    . ~/.bashrc
    npx mocha $@
  else
    # Run bash when no argument
    export PS1='[\u@\h : \w]\$ '
    /bin/bash
  fi
else
  npm run test:local
fi
