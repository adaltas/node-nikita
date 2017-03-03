
nikita = require '../../src'
test = require '../test'
fs = require 'fs'

describe 'options "once"', ->

  scratch = test.scratch @

  describe 'true', ->
    
    it 'detect same handler', ->
      logs = []
      nikita
      .call once: true, handler: (-> logs.push 'a')
      .call once: true, handler: (-> logs.push 'a')
      .then -> logs.should.eql ['a']
          
    it 'detect different handler', ->
      logs = []
      nikita
      .call once: true, handler: (-> logs.push 'a')
      .call once: true, handler: (-> logs.push 'b')
      .then -> logs.should.eql ['a', 'b']

  describe 'string', ->
    
    it 'detect same handler', ->
      logs = []
      nikita
      .call once: 'a', handler: (-> logs.push 'a')
      .call once: 'a', handler: (-> logs.push 'a')
      .then -> logs.should.eql ['a']
    
    it 'detect different handler', ->
      logs = []
      nikita
      .call once: 'a', handler: (-> logs.push 'a')
      .call once: 'b', handler: (-> logs.push 'b')
      .then -> logs.should.eql ['a', 'b']

  describe 'array', ->
    
    it 'detect same handler', ->
      logs = []
      nikita
      .call key_1: 'a', key_2: 'b', once: ['key_1', 'key_2'], handler: (-> logs.push 'a')
      .call key_1: 'a', key_2: 'b', once: ['key_1', 'key_2'], handler: (-> logs.push 'b')
      .then -> logs.should.eql ['a']
    
    it 'detect different handler', ->
      logs = []
      nikita
      .call key_1: 'a', key_2: 'b', once: ['key_1', 'key_2'], handler: (-> logs.push 'a')
      .call key_1: 'c', key_2: 'd', once: ['key_1', 'key_2'], handler: (-> logs.push 'b')
      .then -> logs.should.eql ['a', 'b']
      
