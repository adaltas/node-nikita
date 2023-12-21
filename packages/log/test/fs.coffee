
import nikita from '@nikitajs/core'
import utils from '@nikitajs/core/utils'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'log.fs', ->
  return unless test.tags.posix

  they 'requires option "serializer"', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @log.fs basedir: tmpdir
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'one error was found in the configuration of action `log.fs`:'
          '#/definitions/config/required config must have required property \'serializer\'.'
        ].join ' '

  they 'serializer can be empty', ({ssh}) ->
    return unless ssh
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @log.fs
        basedir: tmpdir
        serializer: {}
      await @call ({tools: {log}}) ->
        log message: 'ok'
      await @fs.assert
        target: "#{tmpdir}/#{ssh?.host or 'local'}.log"
        content: ''

  they 'default options', ({ssh}) ->
    # Note, the fs stream is at the moment never closed
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      await @log.fs
        basedir: tmpdir
        serializer: text: (log) -> "#{log.message}\n"
      await @call ({tools: {events, log}}) ->
        log message: 'ok'
      await @fs.assert
        target: "#{tmpdir}/#{ssh?.host or 'local'}.log"
        content: 'ok\n'

  they 'filename relative with parent dir', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @log.fs
        basedir: tmpdir
        filename: './log/test.log'
        serializer: text: (log) -> "#{log.message}\n"
      await @call ({tools: {log}}) ->
        log message: 'ok'
      await @fs.assert
        target: "#{tmpdir}/log/test.log"
        content: 'ok\n'

  describe 'archive', ->

    they 'archive default directory name', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        await @log.fs
          basedir: tmpdir
          serializer: text: (log) -> "#{log.message}\n"
          archive: true
        await @call ({tools: {log}}) ->
          log message: 'ok'
        now = new Date()
        dir = "#{now.getFullYear()}".slice(-2) + "0#{now.getFullYear()}".slice(-2) + "0#{now.getDate()}".slice(-2)
        await @fs.assert
          target: "#{tmpdir}/#{dir}/#{ssh?.host or 'local'}.log"
          content: 'ok\n'

    they 'latest', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        await @log.fs
          basedir: tmpdir
          serializer: text: (log) -> "#{log.message}\n"
          archive: true
        await @call ({tools: {log}})->
          log message: 'ok'
        {stats} = await @fs.base.lstat "#{tmpdir}/latest"
        utils.stats.isSymbolicLink(stats.mode).should.be.true()
        await @fs.assert
          target: "#{tmpdir}/latest/#{ssh?.host or 'local'}.log"
          content: 'ok\n'
