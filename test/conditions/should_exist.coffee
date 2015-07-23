
they = require 'ssh2-they'
conditions = require '../../src/misc/conditions'

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