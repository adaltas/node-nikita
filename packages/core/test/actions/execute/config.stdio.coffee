
import nikita from '@nikitajs/core'
import test from '../../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'actions.execute.config.stdio', ->
  return unless test.tags.posix
    
  it 'invalid', ->
    nikita.execute
      command: 'abc'
      stdio: 1234
    .should.be.rejectedWith
      code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
  
  it 'valid string', ->
    nikita.execute
      command: 'abc'
      stdio: 'overlapped'
    , ({config})->
      config.stdio.should.eql [ 'overlapped' ]
  
  it 'valid integer', ->
    nikita.execute
      command: 'abc'
      stdio: 1
    , ({config})->
      config.stdio.should.eql [ 1 ]
  
  it 'valid array', ->
    nikita.execute
      command: 'abc'
      stdio: ['overlapped', 'overlapped']
    , ({config})->
      config.stdio.should.eql ['overlapped', 'overlapped']
