#!/bin/bash

: ${TEST_FILES:='test'}

service sshd start

# kadmin NODE.DC1.CONSUL -p admin/admin -s krb5 -w admin -q 'listprincs'
until echo admin | kinit admin/admin
do
  echo 'waiting for kinit to succeed'
  sleep 4
done

if [ $DEBUG -eq '1' ]; then
  /bin/bash
else
  node_modules/.bin/mocha $TEST_FILES
fi

# For debuging purpose
#sleep 10000
