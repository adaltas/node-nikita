
nikita = require '../../../src'
utils = require '../../../src/utils'
{tags, ssh} = require '../../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'actions.log.fs', ->

  they 'requires option "serializer"', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @log.fs basedir: tmpdir
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'one error was found in the configuration of action log.fs:'
          '#/required config should have required property \'serializer\'.'
        ].join ' '

  they 'serializer can be empty', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @log.fs
        basedir: tmpdir
        serializer: {}
      @call ({log}) ->
        log message: 'ok'
      # .file.assert
      #   source: "#{tmpdir}/localhost.log"
      #   content: ''
      #   log: false
      @fs.assert
        target: "#{tmpdir}/localhost.log"
        content: ''

  they 'default options', ({ssh}) ->
    # Note, the fs stream is at the moment never closed
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}})->
      @log.fs
        basedir: tmpdir
        serializer: text: (log) -> "#{log.message}\n"
      @call ({log, operations: {events}}) ->
        log message: 'ok'
      @fs.assert
        target: "#{tmpdir}/localhost.log"
        content: 'ok\n'

  describe 'archive', ->

    they 'archive default directory name', ({ssh}) ->
      nikita
        ssh: ssh
        tmpdir: true
      , ({metadata: {tmpdir}})->
        @log.fs
          basedir: tmpdir
          serializer: text: (log) -> "#{log.message}\n"
          archive: true
        await @call ({log}) ->
          log message: 'ok'
        now = new Date()
        dir = "#{now.getFullYear()}".slice(-2) + "0#{now.getFullYear()}".slice(-2) + "0#{now.getDate()}".slice(-2)
        @fs.assert
          target: "#{tmpdir}/#{dir}/localhost.log"
          content: 'ok\n'

    they 'latest', ({ssh}) ->
      nikita
        ssh: ssh
        tmpdir: true
      , ({metadata: {tmpdir}})->
        @log.fs
          basedir: tmpdir
          serializer: text: (log) -> "#{log.message}\n"
          archive: true
        @call ({log})->
          log message: 'ok'
        {stats} = await @fs.base.lstat "#{tmpdir}/latest"
        utils.stats.isSymbolicLink(stats.mode).should.be.true()
        # @file.assert
        #   source: "#{tmpdir}/latest/localhost.log"
        #   content: /ok/m
        #   log: false
        @fs.assert
          target: "#{tmpdir}/latest/localhost.log"
          content: 'ok\n'
