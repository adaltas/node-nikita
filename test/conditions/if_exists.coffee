
they = require 'ssh2-they'
conditions = require '../../src/misc/conditions'

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

  they 'default to destination if true', (ssh, next) ->
    conditions.unless_exists
      ssh: ssh
      destination: __dirname
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
