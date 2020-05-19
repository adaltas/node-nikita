
nikita = require '../../../src'
{tags} = require '../../test'
err = require '../../../src/utils/error'

return unless tags.api

describe 'metadata.relax', ->

  it 'handler throw error', ->
    {error} = await nikita.call relax: true, ->
      throw Error 'Dont worry, be happy'
    error.message.should.eql 'Dont worry, be happy'

  it 'handler return rejected promise', ->
    {error} = await nikita.call relax: true, ->
      new Promise (resolve, reject) ->
        setImmediate ->
          reject Error 'Dont worry, be happy'
    error.message.should.eql 'Dont worry, be happy'

  it 'handler return rejected promise', ->
    nikita.call ({context}) ->
      context.call ({context}) -> # with parent
        context.call relax: true, ->
          throw Error 'Dont cry, laugh outloud'

  it.skip 'sync with error throw in child', ->
    nikita
    .call relax: true, ->
      @call ->
        throw Error 'Dont worry, be happy'
    , (err) ->
      err.message.should.eql 'Dont worry, be happy'
    .call relax: true, ->
      @call (_, callback)->
        callback Error 'Dont worry, be happy'
    , (err) ->
      err.message.should.eql 'Dont worry, be happy'
    .call -> # with parent
      @call relax: true, ->
        @call ->
          throw Error 'Dont cry, laugh outloud'
      , (err) ->
        err.message.should.eql 'Dont cry, laugh outloud'
    .call -> # with parent
      @call relax: true, ->
        @call (_, callback) ->
          callback Error 'Dont cry, laugh outloud'
      , (err) ->
        err.message.should.eql 'Dont cry, laugh outloud'
    .call ({}, callback) ->
      callback null, true
    .next (err, {status}) ->
      (err is undefined).should.be.true()
      status.should.be.true() unless err
    .promise()
  
  it.skip 'thrown error in callback are handled as an error', ->
    nikita
    .call
      relax: true
    , (->), ->
      throw Error 'Catch me'
    .next (err) ->
      err.message.should.eql 'Catch me'
    .promise()
  
  it.skip 'thrown error in callback are followed to parent sync call', ->
    nikita
    .call level: 'parent', ->
      @call
        level: 'child'
        relax: true
      ,(->), ->
        throw Error 'Catch me'
    .next (err) ->
      err.message.should.eql 'Catch me'
    .promise()

  it.skip 'async', ->
    nikita
    .call relax: true, ({}, callback) ->
      setImmediate ->
        callback Error 'Dont worry, be happy'
    , (err) ->
      err.message.should.eql 'Dont worry, be happy'
    .call ({}, callback) ->
      callback null, true
    .next (err, {status}) ->
      (err is undefined).should.be.true()
      status.should.be.true() unless err
    .promise()

  it 'value should be of type boolean, string, array or regexp', ->
    nikita
    .call relax: 1, (->)
    .should.be.rejectedWith
      message: 'METADATA_RELAX_INVALID_VALUE: configuration `relax` expect a boolean, string, array or regexp value, got 1.'
      code: 'METADATA_RELAX_INVALID_VALUE'

  it 'handler return rejected promise', ->
    {error} = await nikita.call relax: 'NIKITA_ERR', ->
      new Promise (resolve, reject) ->
        setImmediate ->
          reject err 'NIKITA_ERR', ['an error']
    error.message.should.eql 'NIKITA_ERR: an error'

  it 'handler rejects promise with string as param', ->
    nikita.call relax: 'NIKITA_ERR', ->
      new Promise (resolve, reject) ->
        setImmediate ->
          reject err 'NIKITA_OTHER_ERR', ['other error']
    .should.be.rejectedWith
      message: 'NIKITA_OTHER_ERR: other error'
      code: 'NIKITA_OTHER_ERR'

  it 'handler rejects promise with array as param', ->
    nikita.call relax: ['NIKITA_ERR', 'NIKITA_ERR_OTHER'], ->
      new Promise (resolve, reject) ->
        setImmediate ->
          reject err 'NIKITA_OTHER_ERR', ['other error']
    .should.be.rejectedWith
      message: 'NIKITA_OTHER_ERR: other error'
      code: 'NIKITA_OTHER_ERR'

  it 'handler return rejected promise with regexp as param', ->
    {error} = await nikita.call relax: /^NIKITA_/, ->
      new Promise (resolve, reject) ->
        setImmediate ->
          reject err 'NIKITA_ERR', ['an error']
    error.message.should.eql 'NIKITA_ERR: an error'

  it 'handler rejects promise with regexp as param', ->
    nikita.call relax: /^NIKITA_ERR/, ->
      new Promise (resolve, reject) ->
        setImmediate ->
          reject err 'NIKITA_OTHER_ERR', ['other error']
    .should.be.rejectedWith
      message: 'NIKITA_OTHER_ERR: other error'
      code: 'NIKITA_OTHER_ERR'
