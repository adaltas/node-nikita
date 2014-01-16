
fs = require 'fs'
http = require 'http'
should = require 'should'
they = require 'superexec/lib/they'
conditions = if process.env.MECANO_COV then require '../lib-cov/conditions' else require '../lib/conditions'

describe 'conditions', ->

  describe 'if', ->

    they 'should bypass if not present', (ssh, next) ->
      conditions.if
        ssh: ssh
        () -> should.be.ok false
        next

    they 'should succeed if `true`', (ssh, next) ->
      conditions.if
        ssh: ssh
        if: true
        () -> should.be.ok false
        next

    they 'should failed if `false`', (ssh, next) ->
      conditions.if
        ssh: ssh
        if: false
        next
        () -> should.be.ok false

    they 'should succeed on `succeed` callback', (ssh, next) ->
      conditions.if
        ssh: ssh
        if: (options, failed, succeed) -> succeed()
        () -> should.be.ok false
        next

    they 'should failed on `failed` callback', (ssh, next) ->
      conditions.if
        ssh: ssh
        if: (options, failed, succeed) -> failed()
        next
        () -> should.be.ok false

    they 'should pass error object on `failed` callback', (ssh, next) ->
      conditions.if
        ssh: ssh
        if: (options, failed, succeed) -> failed new Error 'cool'
        (err) -> err.message is 'cool' and next()
        () -> should.be.ok false

  describe 'if_exists', ->

    they 'should pass if not present', (ssh, next) ->
      conditions.if_exists
        ssh: ssh
        () -> should.be.ok false
        next

    they 'should succeed if dir exists', (ssh, next) ->
      conditions.if_exists
        ssh: ssh
        if_exists: __dirname
        () -> should.be.ok false
        -> next()

    they 'should skip if file does not exists', (ssh, next) ->
      conditions.if_exists
        ssh: ssh
        if_exists: './oh_no'
        next
        () -> should.be.ok false

    they 'should succeed if all files exists', (ssh, next) ->
      conditions.if_exists
        ssh: ssh
        if_exists: [__dirname, __filename]
        () -> should.be.ok false
        -> next()

    they 'should skip if at least one file exists', (ssh, next) ->
      conditions.if_exists
        ssh: ssh
        if_exists: [__dirname, './oh_no']
        next
        () -> should.be.ok false


  describe 'not_if_exists', ->

    they 'succeed if not present', (ssh, next) ->
      conditions.not_if_exists
        ssh: ssh        
        () -> should.be.ok false
        next

    they 'skip if dir exists', (ssh, next) ->
      conditions.not_if_exists
        ssh: ssh
        not_if_exists: __dirname
        next
        () -> should.be.ok false

    they 'succeed if dir does not exists', (ssh, next) ->
      conditions.not_if_exists
        ssh: ssh
        not_if_exists: './oh_no'
        () -> should.be.ok false
        -> next()

    they 'succeed if no file exists', (ssh, next) ->
      conditions.not_if_exists
        ssh: ssh
        not_if_exists: ['./oh_no', './eh_no']
        () -> should.be.ok false
        -> next()

    they 'skip if at least one file exists', (ssh, next) ->
      conditions.not_if_exists
        ssh: ssh
        not_if_exists: ['./oh_no', __filename]
        next
        () -> should.be.ok false

  describe 'should_exist', ->
    they 'should succeed if file exists', (ssh, next) ->
      conditions.should_exist
        ssh: ssh
        should_exist: __filename
        () -> should.be.ok false
        -> next()

    they 'should failed if file does not exist', (ssh, next) ->
      conditions.should_exist
        ssh: ssh
        should_exist: './oh_no'
        (err) ->
          err.should.be.an.Object
          next()
        () -> should.be.ok false

    they 'should failed if at least one file does not exist', (ssh, next) ->
      conditions.should_exist
        ssh: ssh
        should_exist: ['./oh_no', __filename]
        (err) ->
          err.should.be.an.Object
          next()
        () -> should.be.ok false

  describe 'should_not_exist', ->
    they 'should succeed if file doesnt exist', (ssh, next) ->
      conditions.should_not_exist
        ssh: ssh
        should_not_exist: './oh_no'
        () -> should.be.ok false
        next

    they 'should failed if file exists', (ssh, next) ->
      conditions.should_not_exist
        ssh: ssh
        should_not_exist: __filename
        (err) ->
          err.should.be.an.Object
          next()
        () -> should.be.ok false

    they 'should failed if at least one file exists', (ssh, next) ->
      conditions.should_not_exist
        ssh: ssh
        should_not_exist: ['./oh_no', __filename]
        (err) ->
          err.should.be.an.Object
          next()
        () -> should.be.ok false






