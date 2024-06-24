
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'file.render', ->
  return unless test.tags.posix

  describe 'error', ->

    they 'when option "source" doesnt exist', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file.render
          source: "#{tmpdir}/oups.hbs"
          target: "#{tmpdir}/output"
          context: {}
        .should.be.rejectedWith [
          'NIKITA_FS_CRS_TARGET_ENOENT:'
          'fail to read a file because it does not exist,'
          "location is \"#{tmpdir}/oups.hbs\"."
        ].join ' '

    they 'when option "context" is missing', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file.render
          content: 'Hello {{ who }}'
          target: "#{tmpdir}/output"
        .should.be.rejectedWith [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'one error was found in the configuration of action `file.render`:'
          '#/required config must have required property \'context\'.'
        ].join ' '

    they 'unsupported source extension', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file.render
          source: 'gohome.et'
          target: "#{tmpdir}/output"
          context: {}
        .should.be.rejectedWith
          message: "Invalid Option: extension '.et' is not supported"

    they 'disable templated', ({ssh}) ->
      nikita
        $ssh: ssh
        $templated: true
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @file.render
          content: 'Got {{ config.target }}'
          target: "#{tmpdir}/output"
          context: config: target: 'overwritte target'
        await @fs.assert
          target: "#{tmpdir}/output"
          content: 'Got overwritte target'
  
  describe 'handlebars', ->

    they 'detect `source`', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.writeFile
          target: "#{tmpdir}/source.hbs"
          content: 'Hello {{ who }}'
        await @file.render
          source: "#{tmpdir}/source.hbs"
          target: "#{tmpdir}/target.txt"
          context: who: 'you'
        .should.be.finally.containEql $status: true
        await @fs.assert
          target: "#{tmpdir}/target.txt"
          content: 'Hello you'

    they 'check autoescaping (disabled)', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @fs.writeFile
          target: "#{tmpdir}/source.hbs"
          content: 'Hello "{{ who }}" \'{{ anInt }}\''
        await @file.render
          source: "#{tmpdir}/source.hbs"
          target: "#{tmpdir}/target.txt"
          context:
            who: 'you'
            anInt: 42
        .should.be.finally.containEql $status: true
        await @fs.assert
          target: "#{tmpdir}/target.txt"
          content: 'Hello "you" \'42\''
