
nikita = require '../../../src'
{tags, ssh} = require '../../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'plugin.condition unless_exists', ->

  they 'skip if file exists', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {called} = await @call
        unless_exists: "#{tmpdir}"
        handler: -> called: true
      (called is undefined).should.be.true()

  they 'run if file doesnt exist', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @call
        unless_exists: "#{tmpdir}/toto"
        handler: -> 'called'
      .should.be.finally.eql 'called'
