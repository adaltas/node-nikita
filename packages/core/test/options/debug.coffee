
nikita = require '../../src'
{tags} = require '../test'

return unless tags.api

describe 'options "debug"', ->
  
  it 'print to stderr', ->
    data = []
    write = process.stderr.write
    process.stderr.write = (chunk) -> data.push chunk
    nikita
    .call debug: true, ->
      @log 'Some message'
    .next (err) ->
      throw err if err
      # TODO: detect isTTY
      data.join().should.eql '\u001b[32m[1.INFO undefined] "Some message"\u001b[39m\n'
      process.stderr.write = write
    .promise()
    
  it 'print to stdout', ->
    data = []
    write = process.stdout.write
    process.stdout.write = (chunk) -> data.push chunk
    nikita
    .call debug: 'stdout', ->
      @log 'Some message'
    .next (err) ->
      throw err if err
      # TODO: detect isTTY
      data.join().should.eql '\u001b[32m[1.INFO undefined] "Some message"\u001b[39m\n'
      process.stdout.write = write
    .promise()
  
