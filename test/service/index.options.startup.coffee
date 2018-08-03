
nikita = require '../../src'
test = require '../test'
they = require 'ssh2-they'

describe 'service options startup', ->
  
  @timeout 30000
  config = test.config()
  return if config.disable_service_startup
  return if config.disable_service_systemctl

  they 'activate startup with boolean true', (ssh) ->
    nikita
      ssh: ssh
    .service.remove
      name: config.service.name
    .service
      name: config.service.name
      chk_name: config.service.chk_name
      startup: true
    , (err, {status}) ->
      status.should.be.true() unless err
    .service
      name: config.service.name
      chk_name: config.service.chk_name
      startup: true
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()
  
  they 'activate startup with boolean false', (ssh) ->
    nikita
      ssh: ssh
    .service.remove
      name: config.service.name
    .service
      name: config.service.name
      chk_name: config.service.chk_name
      startup: false
    , (err, {status}) ->
      status.should.be.true() unless err
    .service
      name: config.service.name
      chk_name: config.service.chk_name
      startup: false
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'activate startup with string', (ssh) ->
    nikita
      ssh: ssh
    .system.execute 'which chkconfig', code_skipped: 1, (err, {status}) ->
      @end() unless status
    .service.remove
      name: config.service.name
    .service
      name: config.service.name
      chk_name: config.service.chk_name
      startup: '235'
    , (err, {status}) ->
      status.should.be.true() unless err
    .service
      chk_name: config.service.chk_name
      startup: '235'
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'detect change in startup', (ssh) ->
    # Startup levels only apply to chkconfig
    # Note, on CentOS 7, chkconfig is installed but Nikita wont use it 
    # if it detect systemctl
    nikita
      ssh: ssh
    .system.execute '! command -v systemctl && command -v chkconfig', relax: true, (err) ->
      @end() if err
    .service.remove
      name: config.service.name
    .service
      chk_name: config.service.chk_name
      startup: '2345'
    , (err, {status}) ->
      status.should.be.true() unless err
    .service
      chk_name: config.service.chk_name
      startup: '2345'
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()
