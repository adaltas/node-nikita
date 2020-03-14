
nikita = require '../../src'

describe 'options `handler`', ->
  
  describe 'root action', ->
    
    it 'return an object', ->
      {key} = await nikita ({metadata, options}) ->
        new Promise (resolve, reject) ->
          resolve key: 'value'
      key.should.eql 'value'
          
    it 'return an object', ->
      {key} = await nikita ({metadata, options}) ->
        key: 'value'
      key.should.eql 'value'
      
  describe 'namespaced action', ->

    it 'return a promise', ->
      {key} = await nikita().call ({metadata}) ->
        new Promise (resolve, reject) ->
          resolve key: 'value'
      key.should.eql 'value'

    it 'return an object', ->
      {key} = await nikita().call ({metadata}) ->
        key: 'value'
      key.should.eql 'value'
