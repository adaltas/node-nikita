
connect = require 'ssh2-connect'
nikita = require '../../../src'
{tags, config} = require '../../test'
# All test are executed with an ssh connection passed as an argument
they = require('mocha-they')(config.filter ({ssh}) -> !!ssh)

return unless tags.posix

describe 'actions.ssh.close', ->

  they 'status is true with a connection', ({ssh}) ->
    nikita
    .ssh.open ssh
    .ssh.close()
    .should.be.finally.containEql status: true

  they 'status is false without a connection', ({ssh}) ->
    nikita
    .ssh.open ssh
    .ssh.close()
    .ssh.close()
    .should.be.finally.containEql status: false

  they 'connection opened', ({ssh}) ->
    {ssh: conn} = await nikita.ssh.open ssh
    nikita ->
      @ssh.close ssh: conn
      .should.be.finally.containEql status: true

  they 'connection already closed', ({ssh}) ->
    {ssh: conn} = await nikita.ssh.open ssh
    nikita ->
      await @ssh.close ssh: conn
      @ssh.close ssh: conn
      .should.be.finally.containEql status: false
