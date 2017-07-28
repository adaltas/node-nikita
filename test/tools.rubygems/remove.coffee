
nikita = require '../../src'
they = require 'ssh2-they'
test = require '../test'

describe 'tools.gem.remove', ->

  scratch = test.scratch @

  they 'remove an existing package', (ssh) ->
    nikita
      ssh: ssh
    .tools.rubygems.install
      name: 'json'
    .tools.rubygems.remove
      name: 'json'
    , (err, status) ->
      status.should.be.true() unless err
    .promise()

  they 'remove a non existing package', (ssh) ->
    nikita
      ssh: ssh
    .tools.rubygems.install
      name: 'json'
    .tools.rubygems.remove
      name: 'json'
    .tools.rubygems.remove
      name: 'json'
    , (err, status) ->
      status.should.be.false() unless err
    .promise()

  they 'remove multiple versions', (ssh) ->
    nikita
      ssh: ssh
    .tools.rubygems.install
      name: 'json'
      version: '2.0.0'
    .tools.rubygems.install
      name: 'json'
      version: '2.1.0'
    .tools.rubygems.remove
      name: 'json'
    , (err, status) ->
      status.should.be.true() unless err
    .tools.rubygems.remove
      name: 'json'
    , (err, status) ->
      status.should.be.false() unless err
    .promise()
