
http = require 'http'
nikita = require '../../src'
memory = require '../../src/core/kv/engines/memory'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.posix

describe 'kv', ->
  
  they 'set then get', (ssh) ->
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
    , (err, {status, key, value}) ->
      status.should.be.true()
      key.should.eql 'a_key'
      value.should.eql 'a value'
    .promise()

  they 'get then set', (ssh) ->
    engine = memory()
    promise = nikita
      ssh: ssh
    .kv.engine
      engine: engine
    .kv.get
      key: 'a_key'
    , (err, {status, key, value}) ->
      status.should.be.true()
      key.should.eql 'a_key'
      value.should.eql 'a value'
    .promise()
    nikita
      ssh: ssh
    .kv.engine
      engine: engine
    .kv.set
      key: 'a_key'
      value: 'a value'
    promise  
