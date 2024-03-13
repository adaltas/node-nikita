
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'incus.init', ->
  return unless test.tags.incus
  
  describe 'schema', ->
  
    it 'Container name is between 1 and 63 characters long', ->
      nikita
      .incus.init
        image: "images:#{test.images.alpine}"
        container: "very-long-long-long-long-long-long-long-long-long-long-long-long-long-name"
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'one error was found in the configuration of action `incus.init`:'
          '#/definitions/config/properties/container/pattern config/container must match pattern'
          '"(^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?!-)$)|(^[a-zA-Z]$)",'
          'pattern is "(^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?!-)$)|(^[a-zA-Z]$)".'
        ].join ' '
  
    it 'Container name accepts letters, numbers and dashes from the ASCII table', ->
      nikita
      .incus.init
        image: "images:#{test.images.alpine}"
        container: 'my_name'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'one error was found in the configuration of action `incus.init`:'
          '#/definitions/config/properties/container/pattern config/container must match pattern'
          '"(^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?!-)$)|(^[a-zA-Z]$)",'
          'pattern is "(^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?!-)$)|(^[a-zA-Z]$)".'
        ].join ' '
  
    it 'Container name must not start with a digit', ->
      nikita.incus.init
        image: "images:#{test.images.alpine}"
        container: '1u'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'one error was found in the configuration of action `incus.init`:'
          '#/definitions/config/properties/container/pattern config/container must match pattern'
          '"(^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?!-)$)|(^[a-zA-Z]$)",'
          'pattern is "(^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?!-)$)|(^[a-zA-Z]$)".'
        ].join ' '
    
    it 'Container name must not start with a dash', ->
      nikita.incus.init
        image: "images:#{test.images.alpine}"
        container: '-u1'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'one error was found in the configuration of action `incus.init`:'
          '#/definitions/config/properties/container/pattern config/container must match pattern'
          '"(^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?!-)$)|(^[a-zA-Z]$)",'
          'pattern is "(^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?!-)$)|(^[a-zA-Z]$)".'
        ].join ' '
  
    it 'Container name is not end with a dash', ->
      nikita
      .incus.init
        image: "images:#{test.images.alpine}"
        container: 'u1-'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG:'
          'one error was found in the configuration of action `incus.init`:'
          '#/definitions/config/properties/container/pattern config/container must match pattern'
          '"(^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?!-)$)|(^[a-zA-Z]$)",'
          'pattern is "(^[a-zA-Z][a-zA-Z0-9-]{0,61}[a-zA-Z0-9](?!-)$)|(^[a-zA-Z]$)".'
        ].join ' '
  
  describe 'container', ->
  
    they 'Init a new container', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          @incus.delete 'nikita-init-1', force: true
        await @clean()
        {$status} = await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'nikita-init-1'
        $status.should.be.true()
        await @clean()
        
    they 'Config `start`', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          @incus.delete 'nikita-init-2', force: true
        await @clean()
        await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'nikita-init-2'
          start: true
        {$status} = await @incus.running
          container: 'nikita-init-2'
        $status.should.be.true()
        await @clean()
  
    they 'Validate name', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          @incus.delete 'nikita-init-3', force: true
        await @clean()
        {$status} = await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'nikita-init-3'
        $status.should.be.true()
        await @clean()
  
    they 'Container already exist', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          @incus.delete 'nikita-init-4', force: true
        await @clean()
        await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'nikita-init-4'
        {$status} = await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'nikita-init-4'
        $status.should.be.false()
        await @clean()
    
  describe 'vm', ->
    return unless test.tags.incus_vm

    they 'Init new VM', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          @incus.delete 'nikita-init-vm1', force: true
        await @clean()
        {$status} = await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'nikita-init-vm1'
          vm: true
        $status.should.be.true()
        await @clean()
  
    they 'VM already exist', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          @incus.delete 'nikita-init-vm2', force: true
        await @clean()
        await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'nikita-init-vm2'
          vm: true
        {$status} = await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'nikita-init-vm2'
          vm: true
        $status.should.be.false()
        await @clean()
