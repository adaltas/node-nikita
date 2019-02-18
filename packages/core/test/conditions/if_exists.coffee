
they = require 'ssh2-they'
conditions = require '../../src/misc/conditions'
nikita = require '../../src'
{tags} = require '../test'

return unless tags.api

describe 'if_exists', ->

  they 'should pass if not present', ({ssh}, next) ->
    conditions.if_exists.call nikita(ssh: ssh),
      options: {}
      next
      () -> false.should.be.true()

  they 'should succeed if dir exists', ({ssh}, next) ->
    conditions.if_exists.call nikita(ssh: ssh),
      options:
        if_exists: __dirname
      -> next()
      () -> false.should.be.true()

  they 'should skip if file does not exists', ({ssh}, next) ->
    conditions.if_exists.call nikita(ssh: ssh),
      options:
        if_exists: './oh_no'
      () -> false.should.be.true()
      next

  they 'should fail if at least one file is missing', ({ssh}, next) ->
    conditions.if_exists.call nikita(ssh: ssh),
      options:
        if_exists: [
          __filename
          './oh_no'
          __filename
        ]
      -> false.should.be.true()
      next

  they 'should succeed if all files exist', ({ssh}, next) ->
    conditions.if_exists.call nikita(ssh: ssh),
      options:
        if_exists: [__filename, __filename, __filename]
      -> next()
      (err) -> false.should.be.true()
  
  they 'print log', ({ssh}) ->
    logs = []
    nikita
      ssh: ssh
    .on 'text', (log) -> logs.push log.message
    .call
      if_exists: __filename
      handler: -> logs.push 'handler called'
    .call
      if_exists: __filename + '/does/not/exists'
      handler: -> logs.push 'handler not called'
    .call ->
      logs.should.containEql "File exists #{__filename}, continuing"
      logs.should.containEql 'handler called'
      logs.should.containEql "File doesnt exists #{__filename}/does/not/exists, skipping"
      logs.should.not.containEql 'handler not called'
    .promise()

describe 'unless_exists', ->

  they 'succeed if not present', ({ssh}, next) ->
    conditions.unless_exists.call nikita(ssh: ssh),
      options: {}
      next
      () -> false.should.be.true()

  they 'skip if dir exists', ({ssh}, next) ->
    conditions.unless_exists.call nikita(ssh: ssh),
      options:
        unless_exists: __dirname
      () -> false.should.be.true()
      next

  they 'succeed if dir does not exists', ({ssh}, next) ->
    conditions.unless_exists.call nikita(ssh: ssh),
      options:
        unless_exists: './oh_no'
      -> next()
      () -> false.should.be.true()

  they 'succeed if no file exists', ({ssh}, next) ->
    conditions.unless_exists.call nikita(ssh: ssh),
      options:
        unless_exists: ['./oh_no', './eh_no']
      -> next()
      () -> false.should.be.true()

  they 'default to target if true', ({ssh}, next) ->
    conditions.unless_exists.call nikita(ssh: ssh),
      options:
        target: __dirname
        unless_exists: true
      () -> false.should.be.true()
      -> next()

  they 'skip if at least one file exists', ({ssh}, next) ->
    conditions.unless_exists.call nikita(ssh: ssh),
      options:
        unless_exists: ['./oh_no', __filename]
      () -> false.should.be.true()
      next

  they 'should fail if at least one file exists', ({ssh}, next) ->
    conditions.unless_exists.call nikita(ssh: ssh),
      options:
        unless_exists: ['./oh_no', __filename, './oh_no']
      -> false.should.be.true()
      next

  they 'should succeed if all files are missing', ({ssh}, next) ->
    conditions.unless_exists.call nikita(ssh: ssh),
      options:
        unless_exists: ['./oh_no', './oh_no', './oh_no']
      -> next()
      (err) -> false.should.be.true()
  
  they 'print log', ({ssh}, next) ->
    logs = []
    nikita
      ssh: ssh
    .on 'text', (log) -> logs.push log.message
    .call
      unless_exists: __filename
      handler: -> logs.push 'handler not called'
    .call
      unless_exists: __filename + '/does/not/exists'
      handler: -> logs.push 'handler called'
    .next (err) ->
      logs.should.eql [
        "File exists #{__filename}, skipping"
        "File doesnt exists #{__filename}/does/not/exists, continuing"
        'handler called'
      ] unless err
      next err
