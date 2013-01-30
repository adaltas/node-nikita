
fs = require 'fs'
http = require 'http'
should = require 'should'
conditions = if process.env.MECANO_COV then require '../lib-cov/conditions' else require '../lib/conditions'

describe 'conditions', ->

  describe 'if', ->

    it 'should bypass if not present', (next) ->
      conditions.if(
        {}
        () -> should.be.ok false
        next
      )
    it 'should succeed if `true`', (next) ->
      conditions.if(
        if: true
        () -> should.be.ok false
        next
      )
    it 'should failed if `false`', (next) ->
      conditions.if(
        if: false
        next
        () -> should.be.ok false
      )
    it 'should succeed on `succeed` callback', (next) ->
      conditions.if(
        if: (options, failed, succeed) -> succeed()
        () -> should.be.ok false
        next
      )
    it 'should failed on `failed` callback', (next) ->
      conditions.if(
        if: (options, failed, succeed) -> failed()
        next
        () -> should.be.ok false
      )
    it 'should pass error object on `failed` callback', (next) ->
      conditions.if(
        if: (options, failed, succeed) -> failed new Error 'cool'
        (err) -> err.message is 'cool' and next()
        () -> should.be.ok false
      )

  describe 'if_exists', ->

    it 'should pass if not present', (next) ->
      conditions.if_exists(
        {}
        () -> should.be.ok false
        next
      )
    it 'should succeed if dir exists', (next) ->
      conditions.if_exists(
        if_exists: __dirname
        () -> should.be.ok false
        -> next()
      )
    it 'should skip if file does not exists', (next) ->
      conditions.if_exists(
        if_exists: './oh_no'
        next
        () -> should.be.ok false
      )
    it 'should succeed if all files exists', (next) ->
      conditions.if_exists(
        if_exists: [__dirname, __filename]
        () -> should.be.ok false
        -> next()
      )
    it 'should skip if at least one file exists', (next) ->
      conditions.if_exists(
        if_exists: [__dirname, './oh_no']
        next
        () -> should.be.ok false
      )

  describe 'not_if_exists', ->

    it 'should succeed if not present', (next) ->
      conditions.not_if_exists(
        {}
        () -> should.be.ok false
        next
      )
    it 'should skip if dir exists', (next) ->
      conditions.not_if_exists(
        not_if_exists: __dirname
        next
        () -> should.be.ok false
      )
    it 'should succeed if dir does not exists', (next) ->
      conditions.not_if_exists(
        not_if_exists: './oh_no'
        () -> should.be.ok false
        -> next()
      )
    it 'should succeed if no file exists', (next) ->
      conditions.not_if_exists(
        not_if_exists: ['./oh_no', './eh_no']
        () -> should.be.ok false
        -> next()
      )
    it 'should skip if at least one file exists', (next) ->
      conditions.not_if_exists(
        not_if_exists: ['./oh_no', __filename]
        next
        () -> should.be.ok false
      )

  describe 'should_exist', ->
    it 'should succeed if file exists', (next) ->
      conditions.should_exist(
        should_exist: __filename
        () -> should.be.ok false
        -> next()
      )
    it 'should failed if file does not exist', (next) ->
      conditions.should_exist(
        should_exist: './oh_no'
        (err) ->
          err.should.be.a 'object'
          next()
        () -> should.be.ok false
      )
    it 'should failed if at least one file does not exist', (next) ->
      conditions.should_exist(
        should_exist: ['./oh_no', __filename]
        (err) ->
          err.should.be.a 'object'
          next()
        () -> should.be.ok false
      )

  describe 'should_not_exist', ->
    it 'should succeed if file doesnt exist', (next) ->
      conditions.should_not_exist(
        should_not_exist: './oh_no'
        () -> should.be.ok false
        next
      )
    it 'should failed if file exists', (next) ->
      conditions.should_not_exist(
        should_not_exist: __filename
        (err) ->
          err.should.be.a 'object'
          next()
        () -> should.be.ok false
      )
    it 'should failed if at least one file exists', (next) ->
      conditions.should_not_exist(
        should_not_exist: ['./oh_no', __filename]
        (err) ->
          err.should.be.a 'object'
          next()
        () -> should.be.ok false
      )





