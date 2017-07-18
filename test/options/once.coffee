
nikita = require '../../src'
test = require '../test'

describe 'options "once"', ->

  describe 'true', ->

    it 'detect same handler', ->
      logs = []
      nikita
<<<<<<< HEAD
      .call once: true, -> logs.push 'a'
      .call once: true, -> logs.push 'b'
      .call -> logs.should.eql ['a', 'b']
      .promise()
          
=======
      .call once: true, handler: (-> logs.push 'a')
      .call once: true, handler: (-> logs.push 'a')
      .then -> logs.should.eql ['a']

>>>>>>> trailing spaces and typos
    it 'detect different handler', ->
      logs = []
      nikita
      .call once: true, -> logs.push 'a'
      .call once: true, -> logs.push 'b'
      .call -> logs.should.eql ['a', 'b']
      .promise()

  describe 'string', ->

    it 'detect same handler', ->
      logs = []
      nikita
<<<<<<< HEAD
      .call once: 'a', -> logs.push 'a'
      .call once: 'a', -> logs.push 'a'
      .call -> logs.should.eql ['a']
      .promise()
    
=======
      .call once: 'a', handler: (-> logs.push 'a')
      .call once: 'a', handler: (-> logs.push 'a')
      .then -> logs.should.eql ['a']

>>>>>>> trailing spaces and typos
    it 'detect different handler', ->
      logs = []
      nikita
      .call once: 'a', -> logs.push 'a'
      .call once: 'b', -> logs.push 'b'
      .call -> logs.should.eql ['a', 'b']
      .promise()

  describe 'array', ->

    it 'detect same handler', ->
      logs = []
      nikita
<<<<<<< HEAD
      .call key_1: 'a', key_2: 'b', once: ['key_1', 'key_2'], -> logs.push 'a'
      .call key_1: 'a', key_2: 'b', once: ['key_1', 'key_2'], -> logs.push 'b'
      .call ->
        logs.should.eql ['a']
      .promise()
    
    it 'detect different handler', ->
      logs = []
      nikita
      .call key_1: 'a', key_2: 'b', once: ['key_1', 'key_2'], -> logs.push 'a'
      .call key_1: 'c', key_2: 'd', once: ['key_1', 'key_2'], -> logs.push 'b'
      .call ->
        logs.should.eql ['a', 'b']
      .promise()
      
=======
      .call key_1: 'a', key_2: 'b', once: ['key_1', 'key_2'], handler: (-> logs.push 'a')
      .call key_1: 'a', key_2: 'b', once: ['key_1', 'key_2'], handler: (-> logs.push 'b')
      .then -> logs.should.eql ['a']

    it 'detect different handler', ->
      logs = []
      nikita
      .call key_1: 'a', key_2: 'b', once: ['key_1', 'key_2'], handler: (-> logs.push 'a')
      .call key_1: 'c', key_2: 'd', once: ['key_1', 'key_2'], handler: (-> logs.push 'b')
      .then -> logs.should.eql ['a', 'b']
>>>>>>> trailing spaces and typos
