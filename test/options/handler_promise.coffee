
nikita = require '../../src'
fs = require 'fs'

describe 'options "handler" return promise', ->
  
  describe 'resolve', ->

    it 'without argument is called', ->
      called = false
      nikita
      .call
        handler: ->
          new Promise (resolve, reject) ->
            setImmediate ->
              called = true
              resolve()
      , (err, {status}) ->
        status.should.be.false()
      .next (err) ->
        throw err if err
        called.should.be.true()
      .promise()

    it 'status true', ->
      nikita
      .call
        handler: ->
          new Promise (resolve, reject) ->
            setImmediate -> resolve true
      , (err, {status}) ->
        status.should.be.true()
      .promise()

    it 'status false', ->
      nikita
      .call
        handler: ->
          new Promise (resolve, reject) ->
            setImmediate -> resolve false
      , (err, {status}) ->
        status.should.be.false()
      .promise()

    it 'pass object', ->
      nikita
      .call
        handler: ->
          new Promise (resolve, reject) ->
            setImmediate -> resolve {status: true, a_key: 'a value'}
      , (err, {status, a_key}) ->
        status.should.be.true()
        a_key.should.eql 'a value'
      .promise()

    it 'array with first boolean argument is converted to arguments', ->
      nikita
      .call
        handler: ->
          new Promise (resolve, reject) ->
            setImmediate -> resolve [true, '2nd arg']
      , (err, {status}, value) ->
        status.should.be.true()
        value.should.eql '2nd arg'
      .promise()

    it 'array with first object argument is converted to arguments', ->
      nikita
      .call
        handler: ->
          new Promise (resolve, reject) ->
            setImmediate -> resolve [{status: true, a_key: 'a value'}, '2nd arg']
      , (err, {status, a_key}, value) ->
        status.should.be.true()
        a_key.should.eql 'a value'
        value.should.eql '2nd arg'
      .promise()
        
  describe 'reject', ->

    it 'without arguments get default error', ->
      nikita
      .call
        handler: ->
          new Promise (resolve, reject) ->
            setImmediate -> reject()
      , (err, value) ->
        err.message.should.eql 'Rejected Promise: reject called without any arguments'
      .next (err) ->
        err.message.should.eql 'Rejected Promise: reject called without any arguments'
      .promise()

    it 'with an error', ->
      nikita
      .call
        handler: ->
          new Promise (resolve, reject) ->
            setImmediate -> reject Error 'throw me'
      , (err, value) ->
        err.message.should.eql 'throw me'
      .next (err) ->
        err.message.should.eql 'throw me'
      .promise()
  
  describe 'invalid', ->
    
    it 'is incompatible with async mode', ->
      nikita
      .call
        handler: (options, callback) ->
          new Promise (resolve, reject) ->
            setImmediate -> resolve()
      , (err, value) ->
        err.message.should.eql 'Invalid Promise: returning promise is not supported in asynchronuous mode'
      .next (err) ->
        err.message.should.eql 'Invalid Promise: returning promise is not supported in asynchronuous mode'
      .promise()
      
