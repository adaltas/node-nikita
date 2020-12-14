
nikita = require '../../../src'
{tags, ssh} = require '../../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'plugin.condition if_exists', ->
  
  describe 'array', ->

    they 'run if all conditions are `true`', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @call
          if_exists: [
            "#{tmpdir}"
            "#{tmpdir}"
          ]
          handler: -> 'called'
        .should.be.finally.eql 'called'

    they 'skip if one conditions is `false`', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @call
          if_exists: [
            "#{tmpdir}"
            "#{tmpdir}/ohno"
            "#{tmpdir}"
          ]
          handler: -> throw Error 'forbidden'
  
  describe 'string', ->

    they 'run if file exists', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @call
          if_exists: "#{tmpdir}"
          handler: -> 'called'
        .should.be.finally.eql 'called'

    they 'skip if file doesnt exist', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {called} = await @call
          if_exists: "#{tmpdir}/ohno"
          handler: ({metadata}) ->
            called: true
        (called is undefined).should.be.true()
