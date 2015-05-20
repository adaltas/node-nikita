
should = require 'should'
mecano = require "../src"
test = require './test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'cron remove', ->

  rand = Math.random().toString(36).substring(7);
  when_err = Error 'valid when is required'
  cmd_err = Error 'valid cmd is required'

  they 'remove job', (ssh, next) ->
    mecano
      ssh: ssh
    .cron_add
      cmd: "/bin/true #{rand}"
      when: '0 * * * *'
    .cron_remove
      cmd: "/bin/true #{rand}"
    , (err, status) ->
      status.should.be.true
    .cron_remove
      cmd: "/bin/true #{rand}"
      when: '0 * * * *'
    , (err, status) ->
      status.should.be.false
    .then next
