
mecano = require '../../src'
misc = require '../../src/misc'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'write.properties', ->

  scratch = test.scratch @

  they 'overwrite by default', (ssh, next) ->
    # Write the content
    mecano
      ssh: ssh
    .write.properties
      target: "#{scratch}/file.properties"
      content: a_key: 'a value'
    , (err, status) ->
      status.should.be.true() unless err
    .write.properties
      target: "#{scratch}/file.properties"
      content: another_key: 'another value'
    , (err, status) ->
      status.should.be.true() unless err
    .write.properties
      target: "#{scratch}/file.properties"
      content: another_key: 'another value'
    , (err, status) ->
      status.should.be.false() unless err
    .call (_, callback)->
      fs.readFile ssh, "#{scratch}/file.properties", 'ascii', (err, data) ->
        return callback err if err
        data.should.eql "another_key=another value\n"
        callback()
    .then next
    
  they 'honors merge', (ssh, next) ->
    # Write the content
    mecano
      ssh: ssh
    .write.properties
      target: "#{scratch}/file.properties"
      content: a_key: 'a value'
    , (err, status) ->
      status.should.be.true() unless err
    .write.properties
      target: "#{scratch}/file.properties"
      content: another_key: 'another value'
      merge: true
    , (err, status) ->
      status.should.be.true() unless err
    .write.properties
      target: "#{scratch}/file.properties"
      content: another_key: 'another value'
      merge: true
    , (err, status) ->
      status.should.be.false() unless err
    .call (_, callback)->
      fs.readFile ssh, "#{scratch}/file.properties", 'ascii', (err, data) ->
        return callback err if err
        data.should.eql "a_key=a value\nanother_key=another value\n"
        callback()
    .then next
    
  they 'honor separator', (ssh, next) ->
    # Write the content
    mecano
      ssh: ssh
    .write.properties
      target: "#{scratch}/file.properties"
      content: a_key: 'a value'
      separator: ' '
    .write.properties
      target: "#{scratch}/file.properties"
      content: another_key: 'another value'
      separator: ' '
      merge: true
    .call (_, callback)->
      fs.readFile ssh, "#{scratch}/file.properties", 'ascii', (err, data) ->
        return callback err if err
        data.should.eql "a_key a value\nanother_key another value\n"
        callback()
    .then next
