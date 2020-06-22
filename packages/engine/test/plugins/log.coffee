
nikita = require '../../src'

describe 'plugins.log', ->
  
  it 'emit events', ->
    nikita ({log, operations: {events}}) ->
      new Promise (resolve) ->
        events.on 'text', (msg) ->
          resolve msg
        log message: 'getme'
      .should.finally.containEql
        message: 'getme'
        level: 'INFO'
        index: undefined
        module: undefined
        namespace: []
        type: 'text'
        depth: 0
        metadata:
          raw: false
          raw_input: false
          raw_output: false
          namespace: []
          depth: 0
          disabled: false
          relax: false
          attempt: 0
          retry: 1
          # shy: false
          sleep: 3000
        config: {}
        file: 'log.coffee'
        filename: __filename
        line: 16
