
nikita = require '../../src'
they = require 'ssh2-they'
test = require '../test'

describe 'tools.gem.install', ->

  scratch = test.scratch @

  they 'install a non existing package', (ssh) ->
    nikita
      ssh: ssh
    .tools.rubygems.remove
      name: 'json'
    .tools.rubygems.install
      name: 'json'
    , (err, status) ->
      status.should.be.true() unless err
    .promise()

  they 'bypass existing package', (ssh) ->
    nikita
      ssh: ssh
    .tools.rubygems.remove
      name: 'json'
    .tools.rubygems.install
      name: 'json'
    .tools.rubygems.install
      name: 'json'
    , (err, status) ->
      status.should.be.false() unless err
    .promise()

  they 'install multiple versions', (ssh) ->
    nikita
      ssh: ssh
    .tools.rubygems.remove
      name: 'json'
    .tools.rubygems.install
      name: 'json'
      version: '2.0.0'
    .tools.rubygems.install
      name: 'json'
      version: '2.1.0'
    , (err, status) ->
      status.should.be.true() unless err
    .tools.rubygems.install
      name: 'json'
      version: '2.0.0'
    , (err, status) ->
      status.should.be.false() unless err
    .tools.rubygems.install
      name: 'json'
      version: '2.1.0'
    , (err, status) ->
      status.should.be.false() unless err
    .promise()

  they 'local gem', (ssh) ->
    nikita
      ssh: ssh
    .tools.rubygems.remove
      name: 'json'
    .tools.rubygems.fetch
      name: 'json'
      version: '2.1.0'
      cwd: "#{scratch}"
    .tools.rubygems.install
      name: 'json'
      source: "#{scratch}/json-2.1.0.gem"
    , (err, status) ->
      status.should.be.true() unless err
    .tools.rubygems.install
      name: 'json'
      version: '2.1.0'
    , (err, status) ->
      status.should.be.false() unless err
    .promise()
