
mecano = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'file.json', ->

  scratch = test.scratch @

  they 'stringify content to target', (ssh, next) ->
    mecano
      ssh: ssh
    .file
      target: "#{scratch}/target.json"
      content: 'doent have to be valid json'
    .file.json
      target: "#{scratch}/target.json"
      content: user: 'usrval'
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/target.json"
      content: '{"user":"usrval"}'
    .then next

  they 'merge target', (ssh, next) ->
    mecano
      ssh: ssh
    .file
      target: "#{scratch}/target.json"
      content: '{"target":"tarval","user":"overwrite"}'
    .file.json
      target: "#{scratch}/target.json"
      content: 'user': 'usrval'
      merge: true
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/target.json"
      content: '{"target":"tarval","user":"usrval"}'
    .then next

  they 'merge source', (ssh, next) ->
    mecano
      ssh: ssh
    .file
      target: "#{scratch}/source.json"
      content: '{"source":"srcval","user":"overwrite"}'
    .file.json
      source: "#{scratch}/source.json"
      target: "#{scratch}/target.json"
      content: 'user': 'usrval'
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/target.json"
      content: '{"source":"srcval","user":"usrval"}'
    .then next

  they 'merge source and traget', (ssh, next) ->
    mecano
      ssh: ssh
    .file
      target: "#{scratch}/source.json"
      content: '{"source":"srcval","target":"overwrite","user":"overwrite"}'
    .file
      target: "#{scratch}/target.json"
      content: '{"target":"tarval","user":"overwrite"}'
    .file.json
      source: "#{scratch}/source.json"
      target: "#{scratch}/target.json"
      content: 'user': 'usrval'
      merge: true
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/target.json"
      content: '{"source":"srcval","target":"tarval","user":"usrval"}'
    .then next
