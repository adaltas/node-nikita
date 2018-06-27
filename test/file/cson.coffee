
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'file.cson', ->

  scratch = test.scratch @

  they 'stringify content to target', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/target.cson"
      content: 'doent have to be valid cson'
    .file.cson
      target: "#{scratch}/target.cson"
      content: user: 'torval'
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/target.cson"
      content: 'user: \"torval\"'
    .promise()

  they 'merge target', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/target.cson"
      content: '"user": "linus"\n"merge": true'
    .file.cson
      target: "#{scratch}/target.cson"
      content: 'user': 'torval'
      merge: true
    , (err, {status}) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/target.cson"
      content: 'user: \"torval\"\nmerge: true'
    .promise()
