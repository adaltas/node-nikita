
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'system.info.system', ->

  config = test.config()
  return if config.disable_system_info

  they 'with no options', (ssh) ->
    nikita
      ssh: ssh
    .system.info.system (err, {status, system}) ->
      throw err if err
      status.should.be.false()
      Object.keys(system).should.eql [
        'kernel_name', 'kernel_release', 'kernel_version', 
        'nodename', 'operating_system', 'processor'
      ]
      system.kernel_name.should.match /.+/
      system.kernel_release.should.match /.+/
      system.kernel_version.should.match /.+/
      system.nodename.should.match /.+/
      system.operating_system.should.match /.+/
      system.processor.should.match /.+/
    .promise()
