
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'plugin.conditions if_exists', ->
  return unless test.tags.posix
  
  describe 'array', ->

    they 'run if all conditions are `true`', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @call
          $if_exists: [
            "#{tmpdir}"
            "#{tmpdir}"
          ]
          $handler: -> 'called'
        .should.be.finally.eql 'called'

    they 'skip if one conditions is `false`', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @call
          $if_exists: [
            "#{tmpdir}"
            "#{tmpdir}/ohno"
            "#{tmpdir}"
          ]
          $handler: -> throw Error 'forbidden'
  
  describe 'string', ->

    they 'run if file exists', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @call
          $if_exists: "#{tmpdir}"
          $handler: -> 'called'
        .should.be.finally.eql 'called'

    they 'skip if file doesnt exist', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {called} = await @call
          $if_exists: "#{tmpdir}/ohno"
          $handler: ({metadata}) ->
            called: true
        (called is undefined).should.be.true()
