
nikita = require '../../../src'
{tags, ssh} = require '../../test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'actions.log.md', ->
  
  they 'write message', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}})->
      @log.md basedir: tmpdir
      @call ({tools: {log}}) ->
        log message: 'ok'
      # @file.assert
      #   source: "#{tmpdir}/localhost.log"
      #   content: /^ok\n/
      #   log: false
      @fs.assert
        target: "#{tmpdir}/localhost.log"
        content: 'ok\n'
  
  they 'write message and module', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}})->
      @log.md basedir: tmpdir
      @call ({tools: {log}}) ->
        log message: 'ok', module: 'nikita/test/log/md'
      @fs.assert
        target: "#{tmpdir}/localhost.log"
        content: 'ok (1.INFO, written by nikita/test/log/md)\n'

  describe 'header', ->
  
    they 'honors header', ({ssh}) ->
      nikita
        ssh: ssh
        tmpdir: true
      , ({metadata: {tmpdir}})->
        @log.md basedir: tmpdir
        @call header: 'h1', ({tools: {log}}) ->
          log message: 'ok 1'
          await @call ->
            new Promise (resolve) ->
              setTimeout -> 
                resolve()
              , 500
          @call header: 'h2', ({tools: {log}}) ->
            log message: 'ok 2'
        @fs.assert
          target: "#{tmpdir}/localhost.log"
          content: """
          
          # h1
          
          ok 1
          
          ## h1 : h2
          
          ok 2
          
          """
      
    they 'honors header', ({ssh}) ->
      # this currently fail because there is 2 empty lines between the headers
      # instead of only one
      nikita
        ssh: ssh
        tmpdir: true
      , ({metadata: {tmpdir}})->
        @log.md basedir: tmpdir
        @call header: 'h1', ->
          @call header: 'h2', ({tools: {log}}) ->
            log message: 'ok 2'
        @fs.assert
          target: "#{tmpdir}/localhost.log"
          content: """
          
          # h1
          
          ## h1 : h2
          
          ok 2
          
          """

  describe 'execute', ->
    
    they 'honors stdout_stream', ({ssh}) ->
      nikita
        ssh: ssh
        tmpdir: true
      , ({metadata: {tmpdir}})->
        @log.md basedir: tmpdir
        @execute """
        echo 'this is a one line output'
        """
        {data} = await @fs.base.readFile
          target: "#{tmpdir}/localhost.log"
          encoding: 'utf8'
        data.should.containEql """
          ```stdout
          this is a one line output
          
          ```
          """
          
    they 'stdin one line', ({ssh}) ->
      nikita
        ssh: ssh
        tmpdir: true
      , ({metadata: {tmpdir}})->
        @log.md basedir: tmpdir
        @execute """
        echo 'this is a first line'
        """
        {data} = await @fs.base.readFile
          target: "#{tmpdir}/localhost.log"
          encoding: 'utf8'
        data.should.containEql """
          Running Command: `echo 'this is a first line'`
          """
          
    they 'stdin multi line', ({ssh}) ->
      nikita
        ssh: ssh
        tmpdir: true
      , ({metadata: {tmpdir}})->
        @log.md basedir: tmpdir
        @execute """
        echo 'this is a first line'
        echo 'this is a second line'
        """
        {data} = await @fs.base.readFile
          target: "#{tmpdir}/localhost.log"
          encoding: 'utf8'
        data.should.containEql """
          ```stdin
          echo 'this is a first line'
          echo 'this is a second line'
          ```
          """
