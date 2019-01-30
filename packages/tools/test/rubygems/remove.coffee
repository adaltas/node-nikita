
console.log '!! r remove'
nikita = require '@nikitajs/core'
{tags, ssh, scratch, ruby} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.tools_rubygems

describe 'tools.rubygems.remove', ->

  they 'remove an existing package', (ssh) ->
    nikita
      ssh: ssh
      ruby: ruby
    .tools.rubygems.install
      name: 'execjs'
    .tools.rubygems.remove
      name: 'execjs'
    , (err, {status}) ->
      status.should.be.true() unless err
    .promise()

  they 'remove a non existing package', (ssh) ->
    nikita
      ssh: ssh
      ruby: ruby
    .tools.rubygems.install
      name: 'execjs'
    .tools.rubygems.remove
      name: 'execjs'
    .tools.rubygems.remove
      name: 'execjs'
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'remove multiple versions', (ssh) ->
    nikita
      ssh: ssh
      ruby: ruby
    .tools.rubygems.install
      name: 'execjs'
      version: '2.6.0'
    .tools.rubygems.install
      name: 'execjs'
      version: '2.7.0'
    .tools.rubygems.remove
      name: 'execjs'
    , (err, {status}) ->
      status.should.be.true() unless err
    .tools.rubygems.remove
      name: 'execjs'
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()
