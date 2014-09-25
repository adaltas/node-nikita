
fs = require 'fs'
http = require 'http'
they = require 'ssh2-they'
conditions = if process.env.MECANO_COV then require '../lib-cov/conditions' else require '../lib/misc/conditions'

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

    they 'should succeed if `1`', (ssh, next) ->
      conditions.if
        ssh: ssh
        if: 1
        () -> false.should.be.ok
        next

    they 'should fail if `false`', (ssh, next) ->
      conditions.if
        ssh: ssh
        if: false
        next
        () -> false.should.be.ok

    they 'should fail with error if string', (ssh, next) ->
      conditions.if
        ssh: ssh
        if: 'abc'
        (err) ->
          err.message.should.eql "Invalid condition type"
          next()
        () -> false.should.be.ok

    they 'should succeed on `succeed` callback', (ssh, next) ->
      conditions.if
        ssh: ssh
        if: (options, calback) -> calback null, true
        () -> false.should.be.ok
        next

    they 'should fail on `failed` callback', (ssh, next) ->
      conditions.if
        ssh: ssh
        if: (options, callback) -> callback null, false
        next
        () -> false.should.be.ok

    they 'should pass error object on `failed` callback', (ssh, next) ->
      conditions.if
        ssh: ssh
        if: (options, callback) -> callback new Error 'cool'
        (err) -> err.message is 'cool' and next()
        () -> false.should.be.ok

    they 'call callback with single argument', (ssh, next) ->
      conditions.if
        ssh: ssh
        if: (options, callback) -> callback new Error 'cool'
        (err) -> err.message is 'cool' and next()
        () -> false.should.be.ok

  describe 'not_if', ->

    they 'should bypass if not present', (ssh, next) ->
      conditions.not_if
        ssh: ssh
        () -> false.should.be.ok
        next

    they 'should succeed if `true`', (ssh, next) ->
      conditions.not_if
        ssh: ssh
        not_if: true
        next
        () -> false.should.be.ok

    they 'should succeed if `1`', (ssh, next) ->
      conditions.not_if
        ssh: ssh
        not_if: 1
        next
        () -> false.should.be.ok

    they 'should fail if `false`', (ssh, next) ->
      conditions.not_if
        ssh: ssh
        not_if: false
        () -> false.should.be.ok
        next

    they 'should fail with error if string', (ssh, next) ->
      conditions.not_if
        ssh: ssh
        not_if: 'abc'
        (err) ->
          err.message.should.eql "Invalid condition type"
          next()
        () -> false.should.be.ok

    they 'should succeed on `succeed` callback', (ssh, next) ->
      conditions.not_if
        ssh: ssh
        not_if: (options, callback) -> callback null, true
        next
        () -> false.should.be.ok

    they 'should fail on `failed` callback', (ssh, next) ->
      conditions.not_if
        ssh: ssh
        not_if: (options, callback) -> callback null, false
        () -> false.should.be.ok
        next

    they 'should pass error object on `failed` callback', (ssh, next) ->
      conditions.not_if
        ssh: ssh
        not_if: (options, callback) -> callback new Error 'cool'
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

    they 'default to destination if true', (ssh, next) ->
      conditions.not_if_exists
        ssh: ssh
        destination: __dirname
        not_if_exists: true
        -> next()
        () -> false.should.be.ok

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






