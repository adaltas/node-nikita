
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
        () -> false.should.be.ok
        next

    they 'should succeed if `true`', (ssh, next) ->
      conditions.if
        ssh: ssh
        if: true
        () -> false.should.be.ok
        next

    they 'should fail if `false`', (ssh, next) ->
      conditions.if
        ssh: ssh
        if: false
        next
        () -> false.should.be.ok

    they 'should succeed on `succeed` callback', (ssh, next) ->
      conditions.if
        ssh: ssh
        if: (options, failed, succeed) -> succeed()
        () -> false.should.be.ok
        next

    they 'should fail on `failed` callback', (ssh, next) ->
      conditions.if
        ssh: ssh
        if: (options, failed, succeed) -> failed()
        next
        () -> false.should.be.ok

    they 'should pass error object on `failed` callback', (ssh, next) ->
      conditions.if
        ssh: ssh
        if: (options, failed, succeed) -> failed new Error 'cool'
        (err) -> err.message is 'cool' and next()
        () -> false.should.be.ok

  describe 'if_exists', ->

    they 'should pass if not present', (ssh, next) ->
      conditions.if_exists
        ssh: ssh
        () -> false.should.be.ok
        next

    they 'should succeed if dir exists', (ssh, next) ->
      conditions.if_exists
        ssh: ssh
        if_exists: __dirname
        () -> false.should.be.ok
        -> next()

    they 'should skip if file does not exists', (ssh, next) ->
      conditions.if_exists
        ssh: ssh
        if_exists: './oh_no'
        next
        () -> false.should.be.ok

    they 'should succeed if all files exists', (ssh, next) ->
      conditions.if_exists
        ssh: ssh
        if_exists: [__dirname, __filename]
        () -> false.should.be.ok
        -> next()

    they 'should skip if at least one file exists', (ssh, next) ->
      conditions.if_exists
        ssh: ssh
        if_exists: [__dirname, './oh_no']
        next
        () -> false.should.be.ok


  describe 'not_if_exists', ->

    they 'succeed if not present', (ssh, next) ->
      conditions.not_if_exists
        ssh: ssh        
        () -> false.should.be.ok
        next

    they 'skip if dir exists', (ssh, next) ->
      conditions.not_if_exists
        ssh: ssh
        not_if_exists: __dirname
        next
        () -> false.should.be.ok

    they 'succeed if dir does not exists', (ssh, next) ->
      conditions.not_if_exists
        ssh: ssh
        not_if_exists: './oh_no'
        () -> false.should.be.ok
        -> next()

    they 'succeed if no file exists', (ssh, next) ->
      conditions.not_if_exists
        ssh: ssh
        not_if_exists: ['./oh_no', './eh_no']
        () -> false.should.be.ok
        -> next()

    they 'skip if at least one file exists', (ssh, next) ->
      conditions.not_if_exists
        ssh: ssh
        not_if_exists: ['./oh_no', __filename]
        next
        () -> false.should.be.ok

  describe 'if_exec', ->

    they 'should succeed if command succeed', (ssh, next) ->
      conditions.if_exec
        ssh: ssh
        if_exec: "if [ ! -d '/tmp' ]; then exit 1; fi"
        (err) -> false.should.be.ok
        -> next()

    they 'should fail if command succeed', (ssh, next) ->
      conditions.if_exec
        ssh: ssh
        if_exec: "if [ -d '/tmp' ]; then exit 1; fi"
        () -> next()
        -> false.should.be.ok

  describe 'not_if_exec', ->

    they 'should succeed if command fail', (ssh, next) ->
      conditions.not_if_exec
        ssh: ssh
        not_if_exec: "if [ ! -d '/tmp' ]; then exit 1; fi" # ok
        (err) -> next()
        -> false.should.be.ok

    they 'should fail if command fail', (ssh, next) ->
      conditions.not_if_exec
        ssh: ssh
        not_if_exec: "if [ -d '/tmp' ]; then exit 1; fi"
        () -> false.should.be.ok
        -> next()

  describe 'should_exist', ->

    they 'should succeed if file exists', (ssh, next) ->
      conditions.should_exist
        ssh: ssh
        should_exist: __filename
        () -> false.should.be.ok
        -> next()

    they 'should fail if file does not exist', (ssh, next) ->
      conditions.should_exist
        ssh: ssh
        should_exist: './oh_no'
        (err) ->
          err.should.be.an.Object
          next()
        () -> false.should.be.ok

    they 'should fail if at least one file does not exist', (ssh, next) ->
      conditions.should_exist
        ssh: ssh
        should_exist: ['./oh_no', __filename]
        (err) ->
          err.should.be.an.Object
          next()
        () -> false.should.be.ok

  describe 'should_not_exist', ->
    they 'should succeed if file doesnt exist', (ssh, next) ->
      conditions.should_not_exist
        ssh: ssh
        should_not_exist: './oh_no'
        () -> false.should.be.ok
        next

    they 'should fail if file exists', (ssh, next) ->
      conditions.should_not_exist
        ssh: ssh
        should_not_exist: __filename
        (err) ->
          err.should.be.an.Object
          next()
        () -> false.should.be.ok

    they 'should fail if at least one file exists', (ssh, next) ->
      conditions.should_not_exist
        ssh: ssh
        should_not_exist: ['./oh_no', __filename]
        (err) ->
          err.should.be.an.Object
          next()
        () -> false.should.be.ok






