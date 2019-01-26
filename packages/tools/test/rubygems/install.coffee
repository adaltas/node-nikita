
console.log '!! r install'
nikita = require '@nikita/core'
{tags, ssh, scratch, ruby} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.tools_rubygems

describe 'tools.rubygems.install', ->

  they 'install a non existing package', (ssh) ->
    nikita
      ssh: ssh
      ruby: ruby
    .tools.rubygems.remove
      name: 'execjs'
    .tools.rubygems.install
      name: 'execjs'
    , (err, {status}) ->
      status.should.be.true() unless err
    .tools.rubygems.remove
      name: 'execjs'
    .promise()

  they 'bypass existing package', (ssh) ->
    nikita
      ssh: ssh
      ruby: ruby
    .tools.rubygems.remove
      name: 'execjs'
    .tools.rubygems.install
      name: 'execjs'
    .tools.rubygems.install
      name: 'execjs'
    , (err, {status}) ->
      status.should.be.false() unless err
    .tools.rubygems.remove
      name: 'execjs'
    .promise()

  they 'install multiple versions', (ssh) ->
    nikita
      ssh: ssh
      ruby: ruby
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
    .tools.rubygems.remove
      name: 'execjs'
    .promise()

  they 'local gem from file', (ssh) ->
    nikita
      ssh: ssh
      ruby: ruby
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
    .tools.rubygems.remove
      name: 'execjs'
    .promise()

  they 'local gem from glob', (ssh) ->
    nikita
      ssh: ssh
      ruby: ruby
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
    .tools.rubygems.remove
      name: 'execjs'
    .promise()
