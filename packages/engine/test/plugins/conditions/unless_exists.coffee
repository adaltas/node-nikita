
nikita = require '../../../src'
{tags, ssh} = require '../../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'plugin.condition if', ->

  they 'skip if file exists', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @call
        if_exists: "#{tmpdir}"
        handler: -> 'called'
      .should.be.finally.eql 'called'

  they 'run if file doesnt exist', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @call
        if_exists: "#{tmpdir}/toto"
        handler: -> 'called'
      .should.be.finally.eql 'called'
