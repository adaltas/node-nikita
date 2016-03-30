
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'wait', ->

  scratch = test.scratch @

  they 'wait test async', (ssh, next) ->
    before = Date.now()
    mecano
      ssh: ssh
    .wait
      time: 5000
    , (err, status) ->
      interval = Date.now() - before
      (interval > 5000 and interval < 5200).should.be.true()
    .then next

  they 'wait test sync', (ssh, next) ->
    before = Date.now()
    mecano
      ssh: ssh
    .wait
      time: 5000
    .call ->
      interval = Date.now() - before
      (interval > 5000 and interval < 5200).should.be.true()
    .then next
