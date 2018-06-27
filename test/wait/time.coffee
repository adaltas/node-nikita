
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'wait.time', ->

  scratch = test.scratch @

  they 'time as main argument', (ssh) ->
    before = Date.now()
    nikita
      ssh: ssh
    .wait 500
    .wait '500'
    .wait 0
    .call ->
      interval = Date.now() - before
      (interval >= 1000 and interval < 1500).should.be.true()
    .promise()

  they 'before callback', (ssh) ->
    before = Date.now()
    nikita
      ssh: ssh
    .wait
      time: 1000
    , (err, {status}) ->
      interval = Date.now() - before
      (interval >= 1000 and interval < 1500).should.be.true()
    .promise()

  they 'wait before sync call', (ssh) ->
    before = Date.now()
    nikita
      ssh: ssh
    .wait
      time: 1000
    .call ->
      interval = Date.now() - before
      (interval >= 1000 and interval < 1500).should.be.true()
    .promise()
  
  they  'validate argument', (ssh) ->
    before = Date.now()
    nikita
      ssh: ssh
    .wait
      time: 'an': 'object'
      relax: true
    , (err) ->
      err.message.should.eql 'Invalid time format: {"an":"object"}'
    .promise()
