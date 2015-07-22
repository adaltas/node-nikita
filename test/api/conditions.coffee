
fs = require 'fs'
http = require 'http'
they = require 'ssh2-they'
conditions = require '../../src/misc/conditions'

describe 'conditions', ->

  describe 'mix', ->

    it 'bypass if not present', (next) ->
      conditions.all {}, {},
        () -> false.should.be.true()
        next

    it 'handle multiple conditions (1st failed)', (next) ->
      conditions.all {},
        if: false
        not_if: false
        next
        () -> false.should.be.true()

    it 'handle multiple conditions (all ok with undefined)', (next) ->
      conditions.all {},
        if: true
        not_if: undefined
        () -> false.should.be.true()
        next

    it 'handle multiple conditions (2nd failed)', (next) ->
      conditions.all {},
        if: true
        not_if: true
        next
        () -> false.should.be.true()

    it 'handle multiple conditions (all ok)', (next) ->
      conditions.all {},
        if: true
        not_if: [false, false]
        () -> false.should.be.true()
        next

    it 'handle multiple conditions (one not fail)', (next) ->
      conditions.all {},
        if: undefined
        if_exists: undefined
        not_if: undefined
        next
        () -> false.should.be.true()

    it 'handle multiple conditions (one not fail)', (next) ->
      conditions.all {},
        if: true
        not_if: [false, true, false]
        next
        () -> false.should.be.true()

  describe 'if', ->

    # they 'should bypass if not present', (ssh, next) ->
    #   conditions.if
    #     ssh: ssh
    #     () -> false.should.be.true()
    #     next

    they 'should succeed if `true`', (ssh, next) ->
      conditions.if
        ssh: ssh
        if: true
        () -> false.should.be.true()
        next

    they 'should succeed if `1`', (ssh, next) ->
      conditions.if
        ssh: ssh
        if: 1
        () -> false.should.be.true()
        next

    they 'should fail if `false`', (ssh, next) ->
      conditions.if
        ssh: ssh
        if: false
        next
        () -> false.should.be.true()

    they 'should fail if `null`', (ssh, next) ->
      conditions.if
        ssh: ssh
        if: null
        next
        () -> false.should.be.true()

    they 'should fail if `undefined`', (ssh, next) ->
      conditions.if
        ssh: ssh
        if: undefined
        next
        () -> false.should.be.true()

    they 'should succeed if string not empty', (ssh, next) ->
      conditions.if
        ssh: ssh
        if: 'abc'
        () -> false.should.be.true()
        next

    they 'should succeed if template string not empty', (ssh, next) ->
      conditions.if
        ssh: ssh
        if: '{{db.test}}'
        db: test: 'abc'
        () -> false.should.be.true()
        next

    they 'should fail if string empty', (ssh, next) ->
      conditions.if
        ssh: ssh
        if: ''
        next
        () -> false.should.be.true()

    they 'should fail if template string empty', (ssh, next) ->
      conditions.if
        ssh: ssh
        if: '{{db.test}}'
        db: test: ''
        next
        () -> false.should.be.true()

    they 'should succeed on `succeed` sync callback 0 arguments', (ssh, next) ->
      called = true
      conditions.if
        ssh: ssh
        if: -> true
        (err) -> false.should.be.true()
        ->
          called.should.be.true()
          next()

    they 'should succeed on `succeed` sync callback 1 arguments', (ssh, next) ->
      called = true
      conditions.if
        ssh: ssh
        if: (options) -> true
        (err) -> false.should.be.true()
        ->
          called.should.be.true()
          next()

    they 'should fail on `failed` sync callback', (ssh, next) ->
      conditions.if
        ssh: ssh
        if: (options) -> false
        next
        () -> false.should.be.true()

    they 'should succeed on `succeed` async callback', (ssh, next) ->
      called = true
      conditions.if
        ssh: ssh
        if: (options, calback) -> calback null, true
        (err) -> false.should.be.true()
        ->
          called.should.be.true()
          next()

    they 'should fail on `failed` callback', (ssh, next) ->
      conditions.if
        ssh: ssh
        if: (options, callback) -> callback null, false
        next
        () -> false.should.be.true()

    they 'should pass error object on `failed` callback', (ssh, next) ->
      conditions.if
        ssh: ssh
        if: (options, callback) -> callback new Error 'cool'
        (err) -> err.message is 'cool' and next()
        () -> false.should.be.true()

    they 'call callback with single argument', (ssh, next) ->
      conditions.if
        ssh: ssh
        if: (options, callback) -> callback new Error 'cool'
        (err) -> err.message is 'cool' and next()
        () -> false.should.be.true()

  describe 'not_if', ->

    # they 'should bypass if not present', (ssh, next) ->
    #   conditions.not_if
    #     ssh: ssh
    #     () -> false.should.be.true()
    #     next

    they 'should succeed if `true`', (ssh, next) ->
      conditions.not_if
        ssh: ssh
        not_if: true
        next
        () -> false.should.be.true()

    they 'should skip if all true', (ssh, next) ->
      conditions.not_if
        ssh: ssh
        not_if: [true, true, true]
        next
        () -> false.should.be.true()

    they 'should skip if at least one is true', (ssh, next) ->
      conditions.not_if
        ssh: ssh
        not_if: [false, true, false]
        next
        () -> false.should.be.true()

    they 'should run if all false', (ssh, next) ->
      conditions.not_if
        ssh: ssh
        not_if: [false, false, false]
        () -> false.should.be.true()
        next

    they 'should succeed if `1`', (ssh, next) ->
      conditions.not_if
        ssh: ssh
        not_if: 1
        next
        () -> false.should.be.true()

    they 'should fail if `false`', (ssh, next) ->
      conditions.not_if
        ssh: ssh
        not_if: false
        () -> false.should.be.true()
        next

    they 'should fail if `null`', (ssh, next) ->
      conditions.not_if
        ssh: ssh
        not_if: null
        () -> false.should.be.true()
        next

    they 'should fail if string not empty', (ssh, next) ->
      conditions.not_if
        ssh: ssh
        not_if: 'abc'
        next
        () -> false.should.be.true()

    they 'should fail if string not empty', (ssh, next) ->
      conditions.not_if
        ssh: ssh
        not_if: ''
        () -> false.should.be.true()
        next

    they 'function succeed on `succeed` callback', (ssh, next) ->
      conditions.not_if
        ssh: ssh
        not_if: (options, callback) -> callback null, true
        next
        () -> false.should.be.true()

    they 'function fail on `failed` callback', (ssh, next) ->
      conditions.not_if
        ssh: ssh
        not_if: (options, callback) -> callback null, false
        () -> false.should.be.true()
        next

    they 'function pass error object on `failed` callback', (ssh, next) ->
      conditions.not_if
        ssh: ssh
        not_if: (options, callback) -> callback new Error 'cool'
        (err) -> err.message is 'cool' and next()
        () -> false.should.be.true()

  describe 'if_exists', ->

    they 'should pass if not present', (ssh, next) ->
      conditions.if_exists
        ssh: ssh
        () -> false.should.be.true()
        next

    they 'should succeed if dir exists', (ssh, next) ->
      conditions.if_exists
        ssh: ssh
        if_exists: __dirname
        () -> false.should.be.true()
        -> next()

    they 'should skip if file does not exists', (ssh, next) ->
      conditions.if_exists
        ssh: ssh
        if_exists: './oh_no'
        next
        () -> false.should.be.true()

    they 'should fail if at least one file is missing', (ssh, next) ->
      conditions.if_exists
        ssh: ssh
        if_exists: [
          __filename
          './oh_no'
          __filename
        ]
        next
        -> false.should.be.true()

    they 'should succeed if all files exist', (ssh, next) ->
      conditions.if_exists
        ssh: ssh
        if_exists: [__filename, __filename, __filename]
        (err) -> false.should.be.true()
        -> next()


  describe 'not_if_exists', ->

    they 'succeed if not present', (ssh, next) ->
      conditions.not_if_exists
        ssh: ssh        
        () -> false.should.be.true()
        next

    they 'skip if dir exists', (ssh, next) ->
      conditions.not_if_exists
        ssh: ssh
        not_if_exists: __dirname
        next
        () -> false.should.be.true()

    they 'succeed if dir does not exists', (ssh, next) ->
      conditions.not_if_exists
        ssh: ssh
        not_if_exists: './oh_no'
        () -> false.should.be.true()
        -> next()

    they 'succeed if no file exists', (ssh, next) ->
      conditions.not_if_exists
        ssh: ssh
        not_if_exists: ['./oh_no', './eh_no']
        () -> false.should.be.true()
        -> next()

    they 'default to destination if true', (ssh, next) ->
      conditions.not_if_exists
        ssh: ssh
        destination: __dirname
        not_if_exists: true
        -> next()
        () -> false.should.be.true()

    they 'skip if at least one file exists', (ssh, next) ->
      conditions.not_if_exists
        ssh: ssh
        not_if_exists: ['./oh_no', __filename]
        next
        () -> false.should.be.true()

    they 'should fail if at least one file exists', (ssh, next) ->
      conditions.not_if_exists
        ssh: ssh
        not_if_exists: ['./oh_no', __filename, './oh_no']
        next
        -> false.should.be.true()

    they 'should succeed if all files are missing', (ssh, next) ->
      conditions.not_if_exists
        ssh: ssh
        not_if_exists: ['./oh_no', './oh_no', './oh_no']
        (err) -> false.should.be.true()
        -> next()

  describe 'if_exec', ->

    they 'should succeed if command succeed', (ssh, next) ->
      conditions.if_exec
        ssh: ssh
        if_exec: "exit 0"
        (err) -> false.should.be.true()
        -> next()

    they 'should fail if command succeed', (ssh, next) ->
      conditions.if_exec
        ssh: ssh
        if_exec: "exit 1"
        () -> next()
        -> false.should.be.true()

    they 'should fail if at least one command fail', (ssh, next) ->
      conditions.if_exec
        ssh: ssh
        if_exec: [
          "exit 0"
          "exit 1"
          "exit 0"
        ]
        next
        -> false.should.be.true()

    they 'should succeed if all commands succeeed', (ssh, next) ->
      conditions.if_exec
        ssh: ssh
        if_exec: [
          "exit 0"
          "exit 0"
          "exit 0"
        ]
        (err) -> false.should.be.true()
        -> next()

  describe 'not_if_exec', ->

    they 'should succeed if command fail', (ssh, next) ->
      conditions.not_if_exec
        ssh: ssh
        not_if_exec: "exit 0"
        next
        -> false.should.be.true()

    they 'should fail if command fail', (ssh, next) ->
      conditions.not_if_exec
        ssh: ssh
        not_if_exec: "exit 1"
        () -> false.should.be.true()
        -> next()

    they 'should fail if at least one command succeeed', (ssh, next) ->
      conditions.not_if_exec
        ssh: ssh
        not_if_exec: [
          "exit 1"
          "exit 0"
          "exit 1"
        ]
        next
        -> false.should.be.true()

    they 'should succeed if all commands fail', (ssh, next) ->
      conditions.not_if_exec
        ssh: ssh
        not_if_exec: [
          "exit 1"
          "exit 1"
          "exit 1"
        ]
        (err) -> false.should.be.true()
        -> next()

  describe 'should_exist', ->

    they 'should succeed if file exists', (ssh, next) ->
      conditions.should_exist
        ssh: ssh
        should_exist: __filename
        () -> false.should.be.true()
        -> next()

    they 'should fail if file does not exist', (ssh, next) ->
      conditions.should_exist
        ssh: ssh
        should_exist: './oh_no'
        (err) ->
          err.should.be.an.Object
          next()
        () -> false.should.be.true()

    they 'should fail if at least one file does not exist', (ssh, next) ->
      conditions.should_exist
        ssh: ssh
        should_exist: ['./oh_no', __filename]
        (err) ->
          err.should.be.an.Object
          next()
        () -> false.should.be.true()

  describe 'should_not_exist', ->

    they 'should succeed if file doesnt exist', (ssh, next) ->
      conditions.should_not_exist
        ssh: ssh
        should_not_exist: './oh_no'
        () -> false.should.be.true()
        next

    they 'should fail if file exists', (ssh, next) ->
      conditions.should_not_exist
        ssh: ssh
        should_not_exist: __filename
        (err) ->
          err.should.be.an.Object
          next()
        () -> false.should.be.true()

    they 'should fail if at least one file exists', (ssh, next) ->
      conditions.should_not_exist
        ssh: ssh
        should_not_exist: ['./oh_no', __filename]
        (err) ->
          err.should.be.an.Object
          next()
        () -> false.should.be.true()

  # describe: 'template', ->

  #   they 'inject context', (ssh, next) ->







