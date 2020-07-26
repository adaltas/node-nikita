
connect = require 'ssh2-connect'
nikita = require '../../../src'
utils = require '../../../src/utils'
{tags, ssh} = require '../../test'
# All test are executed with an ssh connection passed as an argument
they = require('ssh2-they').configure ssh.filter (ssh) -> !!ssh

return unless tags.posix

describe 'actions.ssh.root', ->
  
  describe 'schema', ->
    
    they 'config.selinux is invalid', ({ssh}) ->
      nikita
      .ssh.root {...ssh.config, selinux: '_invalid_', debug: undefined}
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG: multiple errors where found in the configuration:'
          '#/properties/selinux/oneOf config.selinux should match exactly one schema in oneOf;'
          '#/properties/selinux/oneOf/0/enum config.selinux should be equal to one of the allowed values;'
          '#/properties/selinux/oneOf/1/type config.selinux should be boolean.'
        ].join ' '
          
    they 'config.selinux is valid', ({ssh}) ->
      nikita
      .ssh.root {...ssh.config, selinux: 'permissive', debug: undefined}, metadata: dry: true
      .should.be.resolvedWith status: false
