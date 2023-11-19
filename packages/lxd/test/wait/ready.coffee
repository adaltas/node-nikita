
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'lxc.wait.ready', ->

  describe 'For containers', ->
    return unless test.tags.lxd

    they 'wait for the container to be ready', ({ssh})  ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        await registry.register 'clean', ->
          await @lxc.delete 
            container: 'nikita-wait-1'
            force: true
        await registry.register 'test', ->
          await @lxc.init
            image: "images:#{test.images.alpine}"
            container: 'nikita-wait-1'
            start: true
          {$status} = await @lxc.wait.ready 'nikita-wait-1'
          $status.should.be.true()
        try 
          await @clean()
          await @test()
        finally
          await @clean()
  
  describe 'For virtual machines', ->
    return unless test.tags.lxd_vm

    they 'wait for the virtual machine to be ready', ({ssh})  ->
      @timeout -1
      nikita
        $ssh: ssh
      , ({registry}) ->
        await registry.register 'clean', ->
          await @lxc.delete 
            container: 'nikita-wait-2'
            force: true
        await registry.register 'test', ->
          await @lxc.init
            image: "images:centos/7"
            container: 'nikita-wait-2'
            vm: true
            properties:
              'security.secureboot': false
            start: true
          {$status} = await @lxc.wait.ready 'nikita-wait-2'
          $status.should.be.true()
        try 
          await @clean()
          await @test()
        finally
          await @clean()
    
    they 'try to execute a command after booting', ({ssh})  ->
      @timeout -1
      nikita
        $ssh: ssh
      , ({registry}) ->
        await registry.register 'clean', ->
          await @lxc.delete 
            container: 'nikita-wait-3'
            force: true
        await registry.register 'test', ->
          await @lxc.init
            image: "images:centos/7"
            container: 'nikita-wait-3'
            vm: true
            properties:
              'security.secureboot': false
            start: true
          await @lxc.wait.ready 'nikita-wait-3'
          {$status} = await @lxc.exec 
            container: 'nikita-wait-3'
            command: '''
            echo "hello"
            '''
          $status.should.be.true()
        try 
          await @clean()
          await @test()
        finally
          await @clean()      
    
    they 'try to execute a command before booting', ({ssh})  ->
      @timeout -1
      nikita
        $ssh: ssh
      , ({registry}) ->
        await registry.register 'clean', ->
          await @lxc.delete 
            container: 'nikita-wait-4'
            force: true
        await registry.register 'test', ->
          await @lxc.init
            image: "images:centos/7"
            container: 'nikita-wait-4'
            vm: true
            properties:
              'security.secureboot': false
            start: true
          {$status} = await @lxc.exec 
            container: 'nikita-wait-4'
            command: '''
            echo "hello"
            '''
        try 
          await @clean()
          await @test()
        catch err
          err.$status.should.be.false()
        finally
          await @clean()      
