#!/bin/bash

service sshd start

# kadmin NODE.DC1.CONSUL -p admin/admin -s krb5 -w admin -q 'listprincs'
until echo admin | kinit admin/admin
do
  echo 'waiting for kinit to succeed'
  sleep 4
done

node_modules/.bin/mocha $@
