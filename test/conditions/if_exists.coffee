
they = require 'ssh2-they'
conditions = require '../../src/misc/conditions'
mecano = require '../../src'

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
  
  they 'print log', (ssh, next) ->
    logs = []
    mecano
    .on 'text', (log) -> logs.push log.message
    .call
      if_exists: __filename
      handler: -> logs.push 'handler called'
    .call
      if_exists: __filename + '/does/not/exists'
      handler: -> logs.push 'handler not called'
    .then (err) ->
      logs.should.eql [
        "File exists #{__filename}, continuing"
        'handler called'
        "File doesnt exists #{__filename}/does/not/exists, skipping"
      ] unless err
      next err

describe 'unless_exists', ->

  they 'succeed if not present', (ssh, next) ->
    conditions.unless_exists
      ssh: ssh        
      () -> false.should.be.true()
      next

  they 'skip if dir exists', (ssh, next) ->
    conditions.unless_exists
      ssh: ssh
      unless_exists: __dirname
      next
      () -> false.should.be.true()

  they 'succeed if dir does not exists', (ssh, next) ->
    conditions.unless_exists
      ssh: ssh
      unless_exists: './oh_no'
      () -> false.should.be.true()
      -> next()

  they 'succeed if no file exists', (ssh, next) ->
    conditions.unless_exists
      ssh: ssh
      unless_exists: ['./oh_no', './eh_no']
      () -> false.should.be.true()
      -> next()

  they 'default to target if true', (ssh, next) ->
    conditions.unless_exists
      ssh: ssh
      target: __dirname
      unless_exists: true
      -> next()
      () -> false.should.be.true()

  they 'skip if at least one file exists', (ssh, next) ->
    conditions.unless_exists
      ssh: ssh
      unless_exists: ['./oh_no', __filename]
      next
      () -> false.should.be.true()

  they 'should fail if at least one file exists', (ssh, next) ->
    conditions.unless_exists
      ssh: ssh
      unless_exists: ['./oh_no', __filename, './oh_no']
      next
      -> false.should.be.true()

  they 'should succeed if all files are missing', (ssh, next) ->
    conditions.unless_exists
      ssh: ssh
      unless_exists: ['./oh_no', './oh_no', './oh_no']
      (err) -> false.should.be.true()
      -> next()
  
  they 'print log', (ssh, next) ->
    logs = []
    mecano
    .on 'text', (log) -> logs.push log.message
    .call
      unless_exists: __filename
      handler: -> logs.push 'handler not called'
    .call
      unless_exists: __filename + '/does/not/exists'
      handler: -> logs.push 'handler called'
    .then (err) ->
      logs.should.eql [
        "File exists #{__filename}, skipping"
        "File doesnt exists #{__filename}/does/not/exists, continuing"
        'handler called'
      ] unless err
      next err
