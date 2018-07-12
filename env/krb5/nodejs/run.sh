#!/bin/bash

# kadmin NODE.DC1.CONSUL -p admin/admin -s krb5 -w admin -q 'listprincs'
until echo admin | kinit admin/admin
do
  echo 'waiting for kinit to succeed'
  sleep 4
done

# We have TTY, so probably an interactive container...
if test -t 0; then
  # Run supervisord detached...
  supervisord -c /etc/supervisord.conf
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
  # Run supervisord in foreground, which will stay until container is stopped.
  supervisord -c /etc/supervisord.conf
  node_modules/.bin/mocha $@
fi
