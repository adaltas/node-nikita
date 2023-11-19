
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'service#config.startup', ->
  return unless test.tags.service_startup or test.tags.service_systemctl

  describe 'schema', ->

    it 'requires config `name`, `srv_name` or `chk_name`', ->
      nikita
      .service
        startup: true
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'multiple errors were found in the configuration of action `service`:'
          '#/dependencies/startup/anyOf config must match a schema in anyOf;'
          '#/dependencies/startup/anyOf/0/required config must have required property \'name\';'
          '#/dependencies/startup/anyOf/1/required config must have required property \'srv_name\';'
          '#/dependencies/startup/anyOf/2/required config must have required property \'chk_name\'.'
        ].join ' '

  describe 'action', ->

    @timeout 30000

    they 'activate startup with boolean true', ({ssh, sudo}) ->
      nikita
        $ssh: ssh
        $sudo: sudo
      , ->
        await @service.remove
          name: test.service.name
        {$status} = await @service
          name: test.service.name
          chk_name: test.service.chk_name
          startup: true
        $status.should.be.true()
        {$status} = await @service
          name: test.service.name
          chk_name: test.service.chk_name
          startup: true
        $status.should.be.false()
    
    they 'activate startup with boolean false', ({ssh, sudo}) ->
      nikita
        $ssh: ssh
        $sudo: sudo
      , ->
        await @service.remove
          name: test.service.name
        {$status} = await @service
          name: test.service.name
          chk_name: test.service.chk_name
          startup: false
        $status.should.be.true()
        {$status} = await @service
          name: test.service.name
          chk_name: test.service.chk_name
          startup: false
        $status.should.be.false()

    they 'activate startup with string', ({ssh, sudo}) ->
      nikita
        $ssh: ssh
        $sudo: sudo
        # Startup levels only apply to chkconfig
        # Note, on CentOS 7, chkconfig is installed but Nikita wont use it
        # if it detect systemctl
        # Note, `-v` flag differ between bash (exit code 1) and sh (exit code 127)
        $if_exec: 'command -v chkconfig && ! command -v systemctl'
      , ->
        {$status} = await @execute 'command -v chkconfig', code: [0, 127], $relax: true
        return unless $status
        await @service.remove
          name: test.service.name
        {$status} = await @service
          name: test.service.name
          chk_name: test.service.chk_name
          startup: '235'
        $status.should.be.true()
        {$status} = await @service
          chk_name: test.service.chk_name
          startup: '235'
        $status.should.be.false()

    they 'detect change in startup level', ({ssh, sudo}) ->
      # Startup levels only apply to chkconfig
      # Note, on CentOS 7, chkconfig is installed but Nikita wont use it
      # if it detect systemctl
      nikita
        $ssh: ssh
        $sudo: sudo
        $if_exec: 'command -v chkconfig && ! command -v systemctl'
      , ->
        await @service.remove
          name: test.service.name
        {$status} = await @service
          name: test.service.name
          chk_name: test.service.chk_name
          startup: '2345'
        $status.should.be.true()
        {$status} = await @service
          chk_name: test.service.chk_name
          startup: '2345'
        $status.should.be.false()
