
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
      @call ({log}) ->
        log message: 'ok'
      # @file.assert
      #   source: "#{tmpdir}/localhost.log"
      #   content: /^ok\n/
      #   log: false
      @fs.base.readFile
        target: "#{tmpdir}/localhost.log"
      .should.be.resolvedWith 'ok\n'
  
  they 'write message and module', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}})->
      @log.md basedir: tmpdir
      @call ({log}) ->
        log message: 'ok', module: 'nikita/test/log/md'
      # @file.assert
      #   source: "#{tmpdir}/localhost.log"
      #   content: /^ok \(1.INFO, written by nikita\/test\/log\/md\)\n/
      #   log: false
      @fs.base.readFile
        target: "#{tmpdir}/localhost.log"
      .should.be.resolvedWith 'ok (1.INFO, written by nikita/test/log/md)\n'

  describe 'header', ->
  
    they 'honors header', ({ssh}) ->
      nikita
        ssh: ssh
        tmpdir: true
      , ({metadata: {tmpdir}})->
        @log.md basedir: tmpdir
        @call header: 'h1', ({log}) ->
          log message: 'ok 1'
          await @call ->
            new Promise (resolve) ->
              setTimeout -> 
                resolve()
              , 500
          @call header: 'h2', ({log}) ->
            log message: 'ok 2'
        @fs.base.readFile
          target: "#{tmpdir}/localhost.log"
        .should.be.resolvedWith """
        
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
          @call header: 'h2', ({log}) ->
            log message: 'ok 2'
        @fs.base.readFile
          target: "#{tmpdir}/localhost.log"
        .should.be.resolvedWith """
          
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
        # @call ({log}) ->
        #   log message: 'this is a one line output', type: 'stdout_stream'
        #   log message: null, type: 'stdout_stream'
        # /^\n```stdout\nthis is a one line output\n```\n\n/
        @fs.base.readFile
          target: "#{tmpdir}/localhost.log"
        .should.finally.containEql """
        
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
        # @call ({log}) ->
        #   log message: 'this is a one line output', type: 'stdout_stream'
        #   log message: null, type: 'stdout_stream'
        # /^\n```stdout\nthis is a one line output\n```\n\n/
        @fs.base.readFile
          target: "#{tmpdir}/localhost.log"
        .should.finally.containEql """
        
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
        # @call ({log}) ->
        #   log message: 'this is a one line output', type: 'stdout_stream'
        #   log message: null, type: 'stdout_stream'
        # /^\n```stdout\nthis is a one line output\n```\n\n/
        @fs.base.readFile
          target: "#{tmpdir}/localhost.log"
        .should.finally.containEql """
        
        ```stdin
        echo 'this is a first line'
        echo 'this is a second line'
        ```
        
        
        """
