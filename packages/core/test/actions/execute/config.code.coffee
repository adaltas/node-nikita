
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'actions.execute.config.code', ->
  return unless test.tags.posix
  
  describe 'normalization', ->
  
    it 'default value', ->
      nikita.execute command: 'exit 0', ({config}) ->
        config.code.should.eql
          true: [0]
          false: []
            
    it 'integer', ->
      nikita.execute
        code: 1
        command: 'exit 1'
      , ({config}) ->
        config.code.should.eql
          true: [1]
          false: []
            
    it 'string', ->
      nikita.execute
        code: '1,2,3'
        command: 'exit 1'
      , ({config}) ->
        config.code.should.eql
          true: [1]
          false: [2,3]
            
    it 'array', ->
      nikita.execute
        code: [1, '2', 3]
        command: 'exit 1'
      , ({config}) ->
        config.code.should.eql
          true: [1]
          false: [2, 3]
            
    it 'array, first element is undefined', ->
      nikita.execute
        code: [, 1, 2]
        command: 'exit 1'
      , ({config}) ->
        config.code.should.eql
          true: []
          false: [1, 2]
            
    it 'array of array', ->
      nikita.execute
        code: [[1, 2], [3, 4]]
        command: 'exit 1'
      , ({config}) ->
        config.code.should.eql
          true: [1, 2]
          false: [3, 4]
            
    it 'object', ->
      nikita.execute
        code: true: 1, false: 2
        command: 'exit 1'
      , ({config}) ->
        config.code.should.eql
          true: [1]
          false: [2]
  
  describe 'value no match', ->

    they 'invalid exit code with default', ({ssh}) ->
      nikita.execute
        command: "exit 42"
        $ssh: ssh
      .should.be.rejectedWith [
        'NIKITA_EXECUTE_EXIT_CODE_INVALID:'
        'an unexpected exit code was encountered,'
        'command is "exit 42",'
        'got 42 instead of {"true":[0],"false":[]}.'
      ].join ' '
  
    they 'invalid exit code unmatching provided codes', ({ssh}) ->
      nikita.execute
        command: "exit 42"
        code: [[1, 2, 3]]
        $ssh: ssh
      .should.be.rejectedWith [
        'NIKITA_EXECUTE_EXIT_CODE_INVALID:'
        'an unexpected exit code was encountered,'
        'command is "exit 42",'
        'got 42 instead of {"true":[1,2,3],"false":[]}.'
      ].join ' '
  
    they 'log error', ({ssh}) ->
      logs = []
      nikita $ssh: ssh, ->
        @execute
          $log: ({log}) ->
            return unless log.type is 'text'
            logs.push log
          command: "exit 1"
        .then -> throw Error 'Oh no'
        .catch ->
          logs.should.match [
            level: 'DEBUG'
            message: 'Command exit with status: 1'
          ,
            level: 'ERROR'
            message: 'An unexpected exit code was encountered, command is "exit 1", got 1 instead of {"true":[0],"false":[]}.'
          ]
    
    they 'log error with metadata.relax', ({ssh}) ->
      logs = []
      nikita $ssh: ssh, ->
        @execute
          $log: ({log}) ->
            return unless log.type is 'text' and log.level isnt 'DEBUG'
            logs.push log
          $relax: true
          command: "exit 1"
        .then -> throw Error 'Oh no'
        .catch ->
          logs.should.match [
            level: 'INFO'
            message: 'An unexpected exit code was encountered, using relax mode, command is "exit 1", got 1 instead of {"true":[0],"false":[]}.'
          ]
  
  describe 'value `true`', ->

    they 'valid exit code', ({ssh}) ->
      nikita $ssh: ssh, ->
        @execute
          command: "exit 42"
          code: [[42, 43]]
        .should.be.resolved()
    
  describe 'value `false`', ->
    
    they 'should honor code skipped', ({ssh}) ->
      nikita $ssh: ssh, ->
        @execute
          command: "exit 42"
          code: [, 42]
        .should.be.finally.containEql $status: false
        @execute
          command: "exit 42"
          code: [, [42, 43]]
        .should.be.finally.containEql $status: false
