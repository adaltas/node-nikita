
validate_container_name = require '../../src/misc/validate_container_name'

describe 'lxd.network.attach', ->
  
  it 'Attach a network to a container', ->
    (->
      validate_container_name ''
    ).should.throw 'Invalid container name: between 1 and 63 characters long'
    (->
      validate_container_name 'oh_no'
    ).should.throw 'Invalid container name: accept letters, numbers and dashes from the ASCII table'
    (->
      validate_container_name '123whynot'
    ).should.throw 'Invalid container name: not start with a digit or a dash'
    (->
      validate_container_name 'sobad-'
    ).should.throw 'Invalid container name: not end with a dash'
