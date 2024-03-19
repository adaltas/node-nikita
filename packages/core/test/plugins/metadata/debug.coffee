
import stream from 'node:stream'
import nikita from '@nikitajs/core'
import test from '../../test.coffee'

describe 'metadata "debug"', ->
  return unless test.tags.api
  
  describe 'validation', ->
  
    it 'invalid string', ->
      nikita
        $debug: 'invalid'
        $handler: -> throw Error 'ohno'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: /metadata\/debug must be equal to one of the allowed values, allowedValues is \["stdout","stderr"\]/
    
    it 'valid string', ->
      await nikita
        $debug: 'stdout'
        $handler: -> 'ok'
      .should.be.fulfilledWith 'ok'
      await nikita
        $debug: 'stderr'
        $handler: -> 'ok'
      .should.be.fulfilledWith 'ok'
  
    it 'valid stream.Writer', ->
      await nikita
        $debug: new stream.Writable()
        $handler: -> 'ok'
      .should.be.fulfilledWith 'ok'
  
    it 'cast to `false`', ->
      # Note, activating schema coercion converted boolean false to a string
      {debug} = await nikita
        $debug: false
        $handler: ({metadata}) -> debug: metadata.debug
      debug.should.be.false()

  describe 'type', ->
  
    it 'text', ->
      data = []
      ws = new stream.Writable()
      ws.write = (chunk) -> data.push chunk
      await nikita.call $debug: ws, ({tools: {log}}) ->
        log 'Some message'
      data.join().should.eql '\u001b[32m[text 1.1 INFO call] Some message\u001b[39m\n'
      
    it 'stdin, stdout, stderr', ->
      data = []
      ws = new stream.Writable()
      ws.write = (chunk) -> data.push chunk
      await nikita.execute
        command: """
        echo to_stdout; echo to_stderr 1>&2
        """
        $debug: ws
      data.join().should.eql [
        '\u001b[33m[stdin 1.1 INFO execute] echo to_stdout; echo to_stderr 1>&2\u001b[39m\n'
        '\u001b[36m[stdout 1.1 INFO execute] to_stdout\u001b[39m\n'
        '\u001b[35m[stderr 1.1 INFO execute] to_stderr\u001b[39m\n'
        '\u001b[32m[text 1.1 DEBUG execute] Command exit with status: 0\u001b[39m\n'
      ].join()
    
  describe 'print', ->
  
    it 'stderr', ->
      data = []
      write = process.stderr.write
      process.stderr.write = (chunk) -> data.push chunk
      await nikita.call
        $debug: true
        $handler: ({tools: {log}}) -> log 'Some message'
      process.stderr.write = write
      data.join().should.eql '\u001b[32m[text 1.1 INFO call] Some message\u001b[39m\n'
      
    it 'stdout', ->
      data = []
      write = process.stdout.write
      process.stdout.write = (chunk) -> data.push chunk
      await nikita.call
        $debug: 'stdout'
        $handler: ({tools: {log}}) -> log 'Some message'
      process.stdout.write = write
      data.join().should.eql '\u001b[32m[text 1.1 INFO call] Some message\u001b[39m\n'
      
    it 'stream writer', ->
      data = []
      ws = new stream.Writable()
      ws.write = (chunk) -> data.push chunk
      await nikita.call
        $debug: ws
        $handler: ({tools: {log}}) -> log 'Some message'
      data.join().should.eql '\u001b[32m[text 1.1 INFO call] Some message\u001b[39m\n'
    
  describe 'cascade', ->
  
    it 'available in children', ->
      data = []
      ws = new stream.Writable()
      ws.write = (chunk) -> data.push chunk
      await nikita.call $debug: ws, ({tools: {log}}) ->
        log 'Parent message'
        await @call (->)
        await @call ({tools: {log}}) ->
          log 'Child message'
      data.join().should.eql [
        '\u001b[32m[text 1.1 INFO call] Parent message\u001b[39m\n'
        '\u001b[32m[text 1.1.2 INFO call] Child message\u001b[39m\n'
      ].join ','
      
    it 'not available in parent', ->
      data = []
      ws = new stream.Writable()
      ws.write = (chunk) -> data.push chunk
      await nikita.call ({tools: {log}}) ->
        log 'Parent message'
        @call $debug: ws, ({tools: {log}}) ->
          log 'Child message'
      data.join().should.eql '\u001b[32m[text 1.1.1 INFO call] Child message\u001b[39m\n'
      
    it 'not available in parent sibling', ->
      data = []
      ws = new stream.Writable()
      ws.write = (chunk) -> data.push chunk
      await nikita
      .call ->
        await @call (->)
        await @call $debug: ws, ({tools: {log}}) ->
          log 'Child message'
      .call ({tools: {log}}) ->
        log 'Sibling message'
      data.join().should.eql '\u001b[32m[text 1.1.2 INFO call] Child message\u001b[39m\n'
  
  
