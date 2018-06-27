
nikita = require '../../src'
they = require 'ssh2-they'
test = require '../test'

describe 'tools.rubygems.install', ->

  config = test.config()
  return if config.disable_tools_rubygems
  scratch = test.scratch @

  they 'install a non existing package', (ssh) ->
    nikita
      ssh: ssh
      ruby: config.ruby
    .tools.rubygems.remove
      name: 'execjs'
    .tools.rubygems.install
      name: 'execjs'
    , (err, {status}) ->
      status.should.be.true() unless err
    .promise()

  they 'bypass existing package', (ssh) ->
    nikita
      ssh: ssh
      ruby: config.ruby
    .tools.rubygems.remove
      name: 'execjs'
    .tools.rubygems.install
      name: 'execjs'
    .tools.rubygems.install
      name: 'execjs'
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'install multiple versions', (ssh) ->
    nikita
      ssh: ssh
      ruby: config.ruby
    .tools.rubygems.remove
      name: 'execjs'
    .tools.rubygems.install
      name: 'execjs'
      version: '2.6.0'
    .tools.rubygems.install
      name: 'execjs'
      version: '2.7.0'
    , (err, {status}) ->
      status.should.be.true() unless err
    .tools.rubygems.install
      name: 'execjs'
      version: '2.6.0'
    , (err, {status}) ->
      status.should.be.false() unless err
    .tools.rubygems.install
      name: 'execjs'
      version: '2.7.0'
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'local gem from file', (ssh) ->
    nikita
      ssh: ssh
      ruby: config.ruby
    .tools.rubygems.remove
      name: 'execjs'
    .tools.rubygems.fetch
      name: 'execjs'
      version: '2.7.0'
      cwd: "#{scratch}"
    .tools.rubygems.install
      name: 'execjs'
      source: "#{scratch}/execjs-2.7.0.gem"
    , (err, {status}) ->
      status.should.be.true() unless err
    .tools.rubygems.install
      name: 'execjs'
      version: '2.7.0'
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'local gem from glob', (ssh) ->
    nikita
      ssh: ssh
      ruby: config.ruby
    .tools.rubygems.remove
      name: 'execjs'
    .tools.rubygems.fetch
      name: 'execjs'
      version: '2.7.0'
      cwd: "#{scratch}"
    .tools.rubygems.install
      name: 'execjs'
      source: "#{scratch}/*.gem"
    , (err, {status}) ->
      status.should.be.true() unless err
    .tools.rubygems.install
      name: 'execjs'
      source: "#{scratch}/*.gem"
    , (err, {status}) ->
      status.should.be.false() unless err
    .tools.rubygems.install
      name: 'execjs'
      version: '2.7.0'
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()
