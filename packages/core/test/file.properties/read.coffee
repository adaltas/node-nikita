
nikita = require '../../src'
misc = require '../../src/misc'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh...

return unless tags.posix

describe 'file.properties.read', ->

  they 'read single key', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/file.properties"
      content: "another_key=another value"
    .file.properties.read
      target: "#{scratch}/file.properties"
    , (err, {properties}) ->
      properties.should.eql another_key: 'another value'
    .promise()

  they 'option separator', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/file.properties"
      content: "another_key:another value"
    .file.properties.read
      target: "#{scratch}/file.properties"
      separator: ':'
    , (err, {properties}) ->
      properties.should.eql another_key: 'another value'
    .promise()

  they 'option trim', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/file.properties"
      content: "another_key : another value"
    .file.properties.read
      target: "#{scratch}/file.properties"
      separator: ':'
      trim: true
    , (err, {properties}) ->
      properties.should.eql another_key: 'another value'
    .promise()
  
  they 'error if target does not exist', ({ssh}) ->
    nikita
      ssh: ssh
    .file.properties.read
      target: "#{scratch}/ohno"
      relax: true
    , (err, {properties}) ->
      err.code.should.eql 'ENOENT'
    .promise()
