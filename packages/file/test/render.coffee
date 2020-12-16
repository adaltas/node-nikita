
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require './test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'file.render', ->

  describe 'error', ->

    they 'when option "source" doesnt exist', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
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
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file.render
          content: 'Hello {{ who }}'
          target: "#{tmpdir}/output"
        .should.be.rejectedWith [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'one error was found in the configuration of action `file.render`:'
          '#/required config should have required property \'context\'.'
        ].join ' '

    they 'unsupported source extension', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @file.render
          source: 'gohome.et'
          target: "#{tmpdir}/output"
          context: {}
        .should.be.rejectedWith
          message: "Invalid Option: extension '.et' is not supported"

  describe 'handlebars', ->

    they 'detect `source`', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.base.writeFile
          target: "#{tmpdir}/source.hbs"
          content: 'Hello {{ who }}'
          metadata: templated: false
        @file.render
          source: "#{tmpdir}/source.hbs"
          target: "#{tmpdir}/target.txt"
          context: who: 'you'
          metadata: templated: false
        .should.be.finally.containEql status: true
        @fs.assert
          target: "#{tmpdir}/target.txt"
          content: 'Hello you'

    they 'check autoescaping (disabled)', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @fs.base.writeFile
          target: "#{tmpdir}/source.hbs"
          content: 'Hello "{{ who }}" \'{{ anInt }}\''
          metadata: templated: false
        @file.render
          source: "#{tmpdir}/source.hbs"
          target: "#{tmpdir}/target.txt"
          context:
            who: 'you'
            anInt: 42
          metadata: templated: false
        .should.be.finally.containEql status: true
        @fs.assert
          target: "#{tmpdir}/target.txt"
          content: 'Hello "you" \'42\''
