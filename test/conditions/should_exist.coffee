
they = require 'ssh2-they'
conditions = require '../../src/misc/conditions'
nikita = require '../../src'

describe 'should_exist', ->

  they 'should succeed if file exists', (ssh, next) ->
    conditions.should_exist.call nikita(),
      ssh: ssh
      should_exist: __filename
      -> next()
      () -> false.should.be.true()

  they 'should fail if file does not exist', (ssh, next) ->
    conditions.should_exist.call nikita(),
      ssh: ssh
      should_exist: './oh_no'
      () -> false.should.be.true()
      (err) ->
        err.should.be.an.Object
        next()

  they 'should fail if at least one file does not exist', (ssh, next) ->
    conditions.should_exist.call nikita(),
      ssh: ssh
      should_exist: ['./oh_no', __filename]
      () -> false.should.be.true()
      (err) ->
        err.should.be.an.Object
        next()

  they 'error propagated to context', (ssh, next) ->
    nikita
    .call should_exist: '/does/not/exist', ->
      throw Error 'Oh no'
    .next (err) ->
      err.message.should.eql 'File does not exist: /does/not/exist'
      next()

describe 'should_not_exist', ->

  they 'should succeed if file doesnt exist', (ssh, next) ->
    conditions.should_not_exist.call nikita(),
      ssh: ssh
      should_not_exist: './oh_no'
      next
      () -> false.should.be.true()

  they 'should fail if file exists', (ssh, next) ->
    conditions.should_not_exist.call nikita(),
      ssh: ssh
      should_not_exist: __filename
      () -> false.should.be.true()
      (err) ->
        err.should.be.an.Object
        next()

  they 'should fail if at least one file exists', (ssh, next) ->
    conditions.should_not_exist.call nikita(),
      ssh: ssh
      should_not_exist: ['./oh_no', __filename]
      () -> false.should.be.true()
      (err) ->
        err.should.be.an.Object
        next()

  they 'error propagated to context', (ssh, next) ->
    nikita
    .call should_not_exist: __filename, ->
      throw Error 'Oh no'
    .next (err) ->
      err.message.should.eql "File does not exist: #{__filename}"
      next()
