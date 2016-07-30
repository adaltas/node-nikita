
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'wait', ->

  scratch = test.scratch @

  they 'time as main argument', (ssh, next) ->
    before = Date.now()
    mecano
      ssh: ssh
    .wait 500
    .wait '500'
    .wait 0
    .call ->
      interval = Date.now() - before
      (interval > 1000 and interval < 1200).should.be.true()
    .then next

  they 'wait before callback', (ssh, next) ->
    before = Date.now()
    mecano
      ssh: ssh
    .wait
      time: 1000
    , (err, status) ->
      interval = Date.now() - before
      (interval > 1000 and interval < 1200).should.be.true()
    .then next

  they 'wait before sync call', (ssh, next) ->
    before = Date.now()
    mecano
      ssh: ssh
    .wait
      time: 1000
    .call ->
      interval = Date.now() - before
      (interval > 1000 and interval < 1200).should.be.true()
    .then next
  
  they  'validate argument', (ssh, next) ->
    before = Date.now()
    mecano
      ssh: ssh
    .wait
      time: 'an': 'object'
    .then (err) ->
      err.message.should.eql 'Invalid time format: {"an":"object"}'
      next()
