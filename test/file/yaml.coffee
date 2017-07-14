
nikita = require '../../src'
misc = require '../../src/misc'
test = require '../test'
they = require 'ssh2-they'

describe 'file.yaml', ->

  scratch = test.scratch @

  they 'stringify an object', (ssh) ->
    nikita
      ssh: ssh
    .file.yaml
      content: user: preference: color: 'rouge'
      target: "#{scratch}/user.yml"
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/user.yml"
      content: 'user:\n  preference:\n    color: rouge\n'
    .promise()

  they 'merge an object', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/user.yml"
      content: 'user:\n  preference:\n    language: english\n'
    .file.yaml
      content: user: preference: language: 'french'
      target: "#{scratch}/user.yml"
      merge: true
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/user.yml"
      content: 'user:\n  preference:\n    language: french\n'
    .promise()

  they 'discard undefined and null', (ssh) ->
    nikita
      ssh: ssh
    .file.yaml
      content: user: preference: color: 'violet', age: undefined, gender: null
      target: "#{scratch}/user.yml"
      merge: true
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/user.yml"
      content: 'user:\n  preference:\n    color: violet\n'
    .promise()

  they 'remove null within merge', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/user.yml"
      content: 'user:\n  preference:\n    country: france\n    language: lovelynode\n    color: rouge\n'
    .file.yaml
      content: user: preference:
        color: 'rouge'
        language: null
      target: "#{scratch}/user.yml"
      merge: true
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/user.yml"
      content: 'user:\n  preference:\n    color: rouge\n    country: france\n'
    .promise()

  they 'disregard undefined within merge', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/user.yml"
      content: 'user:\n  preference:\n    language: node\n    name:    toto\n'
    .file.yaml
      target: "#{scratch}/user.yml"
      content: user: preference:
        language: 'node'
        name: null
      merge: true
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/user.yml"
      content: 'user:\n  preference:\n    language: node\n'
    .promise()

  they 'disregard undefined within merge', (ssh) ->
    nikita
    .file
      target: "#{scratch}/user.yml"
      content: 'user:\n  preference:\n    language: node\n  name: toto\ngroup: hadoop_user\n'
    .file.yaml
      ssh: ssh
      content:
        group: null
      target: "#{scratch}/user.yml"
      merge: true
    , (err, status) ->
      return next err if err
      status.should.be.true()
    .file.assert
      target: "#{scratch}/user.yml"
      content: 'user:\n  preference:\n    language: node\n  name: toto\n'
    .promise()
