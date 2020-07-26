
stream = require 'stream'
nikita = require '../../../src'
{tags} = require '../../test'

return unless tags.api

describe 'metadata "debug"', ->
  
  describe 'type', ->
  
    it 'text', ->
      data = []
      ws = new stream.Writable()
      ws.write = (chunk) -> data.push chunk
      await nikita.call debug: ws, ({log}) ->
        log 'Some message'
      data.join().should.eql '\u001b[32m[1.INFO undefined] Some message\u001b[39m\n'
      
    it 'stdin, stdout, stderr', ->
      data = []
      ws = new stream.Writable()
      ws.write = (chunk) -> data.push chunk
      await nikita.execute
        debug: ws
        cmd: """
        echo to_stdout; echo to_stderr 1>&2
        """
      data.join().should.eql [
        '\u001b[33m[1.INFO nikita/lib/system/execute] echo to_stdout; echo to_stderr 1>&2\u001b[39m\n'
        '\u001b[36m[1.INFO nikita/lib/system/execute] to_stdout\u001b[39m\n'
        '\u001b[35m[1.INFO nikita/lib/system/execute] to_stderr\u001b[39m\n'
      ].join()
    
  describe 'print', ->
  
    it 'stderr', ->
      data = []
      write = process.stderr.write
      process.stderr.write = (chunk) -> data.push chunk
      await nikita.call debug: true, ({log}) ->
        log 'Some message'
      process.stderr.write = write
      data.join().should.eql '\u001b[32m[1.INFO undefined] Some message\u001b[39m\n'
      
    it 'stdout', ->
      data = []
      write = process.stdout.write
      process.stdout.write = (chunk) -> data.push chunk
      await nikita.call debug: 'stdout', ({log}) ->
        log 'Some message'
      process.stdout.write = write
      data.join().should.eql '\u001b[32m[1.INFO undefined] Some message\u001b[39m\n'
      
    it 'stream writer', ->
      data = []
      ws = new stream.Writable()
      ws.write = (chunk) -> data.push chunk
      await nikita.call debug: ws, ({log}) ->
        log 'Some message'
      data.join().should.eql '\u001b[32m[1.INFO undefined] Some message\u001b[39m\n'
  
  describe 'error', ->
      
    it 'invalid string', ->
      nikita
      .call debug: 'oh no', (->)
      .should.be.rejectedWith [
        'METADATA_DEBUG_INVALID_VALUE:'
        'configuration `debug` expect a boolean value,'
        'the string "stdout", or a Node.js Stream Writer,'
        'got "oh no".'
      ].join ' '
  
