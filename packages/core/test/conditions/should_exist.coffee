
conditions = require '../../src/misc/conditions'
nikita = require '../../src'
{tags, config} = require '../test'
they = require('mocha-they')(config)...

return unless tags.posix

describe 'should_exist', ->

  they 'should succeed if file exists', ({ssh}, next) ->
    conditions.should_exist.call nikita(ssh: ssh),
      options:
        should_exist: __filename
      -> next()
      () -> false.should.be.true()

  they 'should fail if file does not exist', ({ssh}, next) ->
    conditions.should_exist.call nikita(ssh: ssh),
      options:
        should_exist: './oh_no'
      () -> false.should.be.true()
      (err) ->
        err.should.be.an.Object
        next()

  they 'should fail if at least one file does not exist', ({ssh}, next) ->
    conditions.should_exist.call nikita(ssh: ssh),
      options:
        should_exist: ['./oh_no', __filename]
      () -> false.should.be.true()
      (err) ->
        err.should.be.an.Object
        next()

  they 'error propagated to session', ({ssh}) ->
    nikita
      ssh: ssh
    .call should_exist: '/does/not/exist', ->
      throw Error 'Oh no'
    .next (err) ->
      err.message.should.eql 'File does not exist: /does/not/exist'
    .promise()

describe 'should_not_exist', ->

  they 'should succeed if file doesnt exist', ({ssh}, next) ->
    conditions.should_not_exist.call nikita(ssh: ssh),
      options:
        should_not_exist: './oh_no'
      next
      () -> false.should.be.true()

  they 'should fail if file exists', ({ssh}, next) ->
    conditions.should_not_exist.call nikita(ssh: ssh),
      options:
        should_not_exist: __filename
      () -> false.should.be.true()
      (err) ->
        err.should.be.an.Object
        next()

  they.skip 'pass error to the callback', ({ssh}) ->
    # TODO: we are not entering inside the callback on error
    nikita
      ssh: ssh
    .call
      should_not_exist: ['./oh_no', __filename]
    , (err) ->
      console.log '!!! This is not called !!!'
    .promise()

  they 'should fail if at least one file exists', ({ssh}) ->
    nikita
      ssh: ssh
    .call
      should_not_exist: ['./oh_no', __filename]
    .next (err) ->
      err.message.should.match /^File does not exist/
    .promise()

  they 'error propagated to session', ({ssh}) ->
    nikita
      ssh: ssh
    .call should_not_exist: __filename, ->
      throw Error 'Oh no'
    .next (err) ->
      err.message.should.eql "File does not exist: #{__filename}"
    .promise()
