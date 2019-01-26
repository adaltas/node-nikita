
nikita = require '../../src'
{tags, ssh, service} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.service_startup or tags.service_systemctl

describe 'service options startup', ->
  
  @timeout 30000

  they 'activate startup with boolean true', (ssh) ->
    nikita
      ssh: ssh
    .service.remove
      name: service.name
    .service
      name: service.name
      chk_name: service.chk_name
      startup: true
    , (err, {status}) ->
      status.should.be.true() unless err
    .service
      name: service.name
      chk_name: service.chk_name
      startup: true
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()
  
  they 'activate startup with boolean false', (ssh) ->
    nikita
      ssh: ssh
    .service.remove
      name: service.name
    .service
      name: service.name
      chk_name: service.chk_name
      startup: false
    , (err, {status}) ->
      status.should.be.true() unless err
    .service
      name: service.name
      chk_name: service.chk_name
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
      name: service.name
    .service
      name: service.name
      chk_name: service.chk_name
      startup: '235'
    , (err, {status}) ->
      status.should.be.true() unless err
    .service
      chk_name: service.chk_name
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
      name: service.name
    .service
      chk_name: service.chk_name
      startup: '2345'
    , (err, {status}) ->
      status.should.be.true() unless err
    .service
      chk_name: service.chk_name
      startup: '2345'
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()
