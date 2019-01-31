
nikita = require '../../src'
{tags, ssh, service} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.service_install

describe 'service.install', ->
  
  @timeout 50000

  they 'new package', (ssh) ->
    nikita
      ssh: ssh
    .service.remove
      name: service.name
    .service
      name: service.name
    , (err, {status}) ->
      status.should.be.true() unless err
    .promise()
  
  they 'already installed packages', (ssh) ->
    nikita
      ssh: ssh
    .service.remove
      name: service.name
    .service
      name: service.name
    .service
      name: service.name
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'name as default argument', (ssh) ->
    nikita
      ssh: ssh
    .service.remove
      name: service.name
    .service service.name, (err, {status}) ->
      status.should.be.true() unless err
    .promise()
  
  they 'cache', (ssh) ->
    nikita
      ssh: ssh
    .service.remove
      name: service.name
    .call ->
      (@store['nikita:execute:installed'] is undefined).should.be.true()
    .service
      name: service.name
      cache: true
    , (err, {status}) ->
      status.should.be.true() unless err
    .call ->
      @store['nikita:execute:installed'].should.containEql service.name
    .promise()

  they 'skip code when error', (ssh) ->
    nikita
      ssh: ssh
    .service.install
      name: 'thisservicedoesnotexist'
      code_skipped: [1, 100] # 1 for RH, 100 for Ubuntu
    , (err, {status}) ->
      status.should.be.false() unless err
    .promise()
  
  describe 'specific', ->
    
    they 'add pacman options', (ssh) ->
      message = null
      nikita
        ssh: ssh
      .on 'stdin', (log) ->
        message = log.message
      .service.remove
        name: service.name
      .service.install
        name: service.name
        pacman_flags: ['u', 'y']
      .call ->
        message.should.containEql "pacman --noconfirm -S #{service.name} -u -y"
      .promise()
        
    they 'add yaourt options', (ssh) ->
      message = null
      nikita
        ssh: ssh
      .on 'stdin', (log) ->
        message = log.message
      .service.remove
        name: service.name
      .service.install
        name: service.name
        yaourt_flags: ['u', 'y']
      .call ->
        message.should.containEql "yaourt --noconfirm -S #{service.name} -u -y"
      .promise()
        
    they 'add yay options', (ssh) ->
      message = null
      nikita
        ssh: ssh
      .on 'stdin', (log) ->
        message = log.message
      .service.remove
        name: service.name
      .service.install
        name: service.name
        yay_flags: ['u', 'y']
      .call ->
        message.should.containEql "yay --noconfirm -S #{service.name} -u -y"
      .promise()
