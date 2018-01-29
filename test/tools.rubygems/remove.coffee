
nikita = require '../../src'
they = require 'ssh2-they'
test = require '../test'

describe 'tools.rubygems.remove', ->

  config = test.config()
  return if config.disable_tools_rubygems
  scratch = test.scratch @

  they 'remove an existing package', (ssh) ->
    nikita
      ssh: ssh
      ruby: config.ruby
    .tools.rubygems.install
      name: 'execjs'
    .tools.rubygems.remove
      name: 'execjs'
    , (err, status) ->
      status.should.be.true() unless err
    .promise()

  they 'remove a non existing package', (ssh) ->
    nikita
      ssh: ssh
      ruby: config.ruby
    .tools.rubygems.install
      name: 'execjs'
    .tools.rubygems.remove
      name: 'execjs'
    .tools.rubygems.remove
      name: 'execjs'
    , (err, status) ->
      status.should.be.false() unless err
    .promise()

  they 'remove multiple versions', (ssh) ->
    nikita
      ssh: ssh
      ruby: config.ruby
    .tools.rubygems.install
      name: 'execjs'
      version: '2.6.0'
    .tools.rubygems.install
      name: 'execjs'
      version: '2.7.0'
    .tools.rubygems.remove
      name: 'execjs'
    , (err, status) ->
      status.should.be.true() unless err
    .tools.rubygems.remove
      name: 'execjs'
    , (err, status) ->
      status.should.be.false() unless err
    .promise()
