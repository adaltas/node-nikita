
stream = require 'stream'
nikita = require '../../../src'
{tags} = require '../../test'

describe 'metadata "debug"', ->
  return unless tags.api
  
  describe 'type', ->
  
    it 'text', ->
      data = []
      ws = new stream.Writable()
      ws.write = (chunk) -> data.push chunk
      await nikita.call metadata: debug: ws, ({tools: {log}}) ->
        log 'Some message'
      data.join().should.eql '\u001b[32m[1.INFO undefined] Some message\u001b[39m\n'
      
    it 'stdin, stdout, stderr', ->
      data = []
      ws = new stream.Writable()
      ws.write = (chunk) -> data.push chunk
      await nikita.execute
        command: """
        echo to_stdout; echo to_stderr 1>&2
        """
        metadata: debug: ws
      data.join().should.eql [
        '\u001b[33m[1.INFO @nikitajs/engine/src/actions/execute] echo to_stdout; echo to_stderr 1>&2\u001b[39m\n'
        '\u001b[36m[1.INFO @nikitajs/engine/src/actions/execute] to_stdout\u001b[39m\n'
        '\u001b[35m[1.INFO @nikitajs/engine/src/actions/execute] to_stderr\u001b[39m\n'
      ].join()
    
  describe 'print', ->
  
    it 'stderr', ->
      data = []
      write = process.stderr.write
      process.stderr.write = (chunk) -> data.push chunk
      await nikita.call metadata: debug: true, ({tools: {log}}) ->
        log 'Some message'
      process.stderr.write = write
      data.join().should.eql '\u001b[32m[1.INFO undefined] Some message\u001b[39m\n'
      
    it 'stdout', ->
      data = []
      write = process.stdout.write
      process.stdout.write = (chunk) -> data.push chunk
      await nikita.call metadata: debug: 'stdout', ({tools: {log}}) ->
        log 'Some message'
      process.stdout.write = write
      data.join().should.eql '\u001b[32m[1.INFO undefined] Some message\u001b[39m\n'
      
    it 'stream writer', ->
      data = []
      ws = new stream.Writable()
      ws.write = (chunk) -> data.push chunk
      await nikita.call metadata: debug: ws, ({tools: {log}}) ->
        log 'Some message'
      data.join().should.eql '\u001b[32m[1.INFO undefined] Some message\u001b[39m\n'
    
  describe 'cascade', ->
  
    it 'available in children', ->
      data = []
      ws = new stream.Writable()
      ws.write = (chunk) -> data.push chunk
      await nikita.call metadata: debug: ws, ({tools: {log}}) ->
        log 'Parent message'
        @call ({tools: {log}}) ->
          log 'Child message'
      data.join().should.eql [
        '\u001b[32m[1.INFO undefined] Parent message\u001b[39m\n'
        '\u001b[32m[2.INFO undefined] Child message\u001b[39m\n'
      ].join ','
      
    it 'not available in parent', ->
      data = []
      ws = new stream.Writable()
      ws.write = (chunk) -> data.push chunk
      await nikita.call ({tools: {log}}) ->
        log 'Parent message'
        @call metadata: debug: ws, ({tools: {log}}) ->
          log 'Child message'
      data.join().should.eql '\u001b[32m[2.INFO undefined] Child message\u001b[39m\n'
      
    it 'not available in parent sibling', ->
      data = []
      ws = new stream.Writable()
      ws.write = (chunk) -> data.push chunk
      await nikita
      .call ->
        @call metadata: debug: ws, ({tools: {log}}) ->
          log 'Child message'
      .call ({tools: {log}}) ->
        log 'Sibling message'
      data.join().should.eql '\u001b[32m[2.INFO undefined] Child message\u001b[39m\n'
  
  describe 'error', ->
      
    it 'invalid string', ->
      nikita
      .call metadata: debug: 'oh no', (->)
      .should.be.rejectedWith [
        'METADATA_DEBUG_INVALID_VALUE:'
        'configuration `debug` expect a boolean value,'
        'the string "stdout", or a Node.js Stream Writer,'
        'got "oh no".'
      ].join ' '
  
