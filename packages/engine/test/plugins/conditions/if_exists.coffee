
nikita = require '../../../src'
{tags, ssh} = require '../../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'plugin.condition if', ->

  they 'run if file exists', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @call
        if_exists: "#{tmpdir}"
        handler: -> 'called'
      .should.be.finally.eql 'called'

  they.skip 'skip if file doesnt exist', ({ssh}) ->
    # TODO, no time to implement this one now
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {called} = await @call
        if_exists: "#{tmpdir}/ohno"
        handler: ({metadata}) ->
          called: true
      (called is undefined).should.be.true()
