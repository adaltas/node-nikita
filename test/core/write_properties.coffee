
mecano = require '../../src'
misc = require '../../src/misc'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'write', ->

  scratch = test.scratch @
  
  they 'overwrite by default', (ssh, next) ->
    # Write the content
    mecano
      ssh: ssh
    .write_properties
      destination: "#{scratch}/file.properties"
      content: a_key: 'a value'
    .write_properties
      destination: "#{scratch}/file.properties"
      content: another_key: 'another value'
    .call (_, callback)->
      fs.readFile ssh, "#{scratch}/file.properties", 'ascii', (err, data) ->
        return callback err if err
        data.should.eql "another_key=another value"
        callback()
    .then next
    
  they 'honors merge', (ssh, next) ->
    # Write the content
    mecano
      ssh: ssh
    .write_properties
      destination: "#{scratch}/file.properties"
      content: a_key: 'a value'
    .write_properties
      destination: "#{scratch}/file.properties"
      content: another_key: 'another value'
      merge: true
    .call (_, callback)->
      fs.readFile ssh, "#{scratch}/file.properties", 'ascii', (err, data) ->
        return callback err if err
        data.should.eql "a_key=a value\nanother_key=another value"
        callback()
    .then next
    
  they 'honor separator', (ssh, next) ->
    # Write the content
    mecano
      ssh: ssh
    .write_properties
      destination: "#{scratch}/file.properties"
      content: a_key: 'a value'
      separator: ' '
    .write_properties
      destination: "#{scratch}/file.properties"
      content: another_key: 'another value'
      separator: ' '
      merge: true
    .call (_, callback)->
      fs.readFile ssh, "#{scratch}/file.properties", 'ascii', (err, data) ->
        return callback err if err
        data.should.eql "a_key a value\nanother_key another value"
        callback()
    .then next
    
  
  
