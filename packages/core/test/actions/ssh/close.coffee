
connect = require 'ssh2-connect'
nikita = require '../../../src'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

describe 'actions.ssh.close', ->
  return unless tags.ssh
  
  describe 'provided connection', ->

    they 'status is true with a connection', ({ssh}) ->
      nikita ->
        {ssh} = await @ssh.open ssh
        @ssh.close ssh: ssh
        .should.be.finally.containEql status: true

    they 'status is false without a connection', ({ssh}) ->
      nikita ->
        {ssh} = await @ssh.open ssh
        @ssh.close ssh: ssh
        @ssh.close ssh: ssh
        .should.be.finally.containEql status: false
        
  describe 'sibling connection', ->

    they 'search for sibling', ({ssh}) ->
      nikita ->
        @ssh.open ssh
        @ssh.close()
        .should.be.finally.containEql status: true

      they 'error if no ssh to close', ({ssh}) ->
        nikita ->
          @ssh.open ssh
          @ssh.close()
          .should.be.rejectedWith
            code: 'NIKITA_SSH_CLOSE_NO_CONN'
