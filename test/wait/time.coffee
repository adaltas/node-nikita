
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'wait', ->

  scratch = test.scratch @

  they 'wait test argument', (ssh, next) ->
    before = Date.now()
    mecano
      ssh: ssh
    .wait 500
    .wait '500'
    .call ->
      interval = Date.now() - before
      (interval > 1000 and interval < 1200).should.be.true()
    .then next

  they 'wait test async', (ssh, next) ->
    before = Date.now()
    mecano
      ssh: ssh
    .wait
      time: 1000
    , (err, status) ->
      interval = Date.now() - before
      (interval > 1000 and interval < 1200).should.be.true()
    .then next

  they 'wait test sync', (ssh, next) ->
    before = Date.now()
    mecano
      ssh: ssh
    .wait
      time: 1000
    .call ->
      interval = Date.now() - before
      (interval > 1000 and interval < 1200).should.be.true()
    .then next
