
nikita = require '../../src'
memory = require '../../src/core/kv/engines/memory'
test = require '../test'
they = require 'ssh2-they'
http = require 'http'

describe 'kv', ->

  scratch = test.scratch @
  
  they 'set then get', (ssh, next) ->
    engine = memory()
    nikita
      ssh: ssh
    .kv.engine
      engine: engine
    .kv.set
      key: 'a_key'
      value: 'a value'
    nikita
      ssh: ssh
    .kv.engine
      engine: engine
    .kv.get
      key: 'a_key'
      value: 'a value'
    , (err, status, key, value) ->
      status.should.be.true()
      key.should.eql 'a_key'
      value.should.eql 'a value'
    .then next
    
  they 'get then set', (ssh, next) ->
    engine = memory()
    nikita
      ssh: ssh
    .kv.engine
      engine: engine
    .kv.get
      key: 'a_key'
      value: 'a value'
    , (err, status, key, value) ->
      status.should.be.true()
      key.should.eql 'a_key'
      value.should.eql 'a value'
    .then next
    nikita
      ssh: ssh
    .kv.engine
      engine: engine
    .kv.set
      key: 'a_key'
      value: 'a value'
      
