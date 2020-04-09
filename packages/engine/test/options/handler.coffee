
nikita = require '../../src'

describe 'config `handler`', ->
  
  describe 'root action', ->
    
    it 'return an object', ->
      {key} = await nikita ->
        new Promise (resolve, reject) ->
          resolve key: 'value'
      key.should.eql 'value'
          
    it 'return an object', ->
      {key} = await nikita ->
        key: 'value'
      key.should.eql 'value'
      
  describe 'namespaced action', ->

    it 'return a promise', ->
      {key} = await nikita().call ->
        new Promise (resolve, reject) ->
          resolve key: 'value'
      key.should.eql 'value'

    it 'return an object', ->
      {key} = await nikita().call ->
        key: 'value'
      key.should.eql 'value'
