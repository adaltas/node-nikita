
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'incus.file.push', ->
  
  describe 'schema', ->
    return unless test.tags.api

    it 'mode symbolic', ->
      nikita.incus.file.push
        container: 'nikita-file-push'
        target: '/root/a_file'
        content: 'something'
        mode: 'u=rwx'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'

    it 'mode coercion', ->
      nikita.incus.file.push
        container: 'nikita-file-push'
        target: '/root/a_file'
        content: 'something'
        mode: '700'
      , ({config}) ->
        config.mode.should.eql 0o0700
  
  describe 'usage', ->
    return unless test.tags.incus
    
    they 'require openssl', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}, registry}) ->
        registry.register 'clean', ->
          await @incus.delete 'nikita-file-push-1', force: true
        await @clean()
        await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'nikita-file-push-1'
          start: true
        await @file.touch
          target: "#{tmpdir}/a_file"
        await @incus.file.push
          container: 'nikita-file-push-1'
          source: "#{tmpdir}/a_file"
          target: '/root/a_file'
        .should.be.rejectedWith
          code: 'NIKITA_INCUS_FILE_PUSH_MISSING_OPENSSL'
        await @clean()

    they 'a new file', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}, registry}) ->
        await registry.register 'clean', ->
          await @incus.delete 
            container: 'nikita-file-push-2'
            force: true
          await @incus.network.delete
            network: 'nktincuspub'
        await registry.register 'test', ->
          # creating network
          await @incus.network
            network: 'nktincuspub'
            properties:
              'ipv4.address': '10.10.40.1/24'
              'ipv4.nat': true
              'ipv6.address': 'none'
          # creating a container
          await @incus.init
            image: "images:#{test.images.alpine}"
            container: 'nikita-file-push-2'
            nic:
              eth0:
                name: 'eth0', nictype: 'bridged', parent: 'nktincuspub'
            ssh: enabled: true
            start: true
          # attaching network
          await @incus.network.attach
            container: 'nikita-file-push-2'
            network: 'nktincuspub'
          # adding openssl for file push
          await @incus.exec
            $retry: 100
            $wait: 200 # Wait for network to be ready
            container: 'nikita-file-push-2'
            command: 'apk add openssl'
          await @file
            target: "#{tmpdir}/a_file"
            content: 'something'
          {$status} = await @incus.file.push
            container: 'nikita-file-push-2'
            source: "#{tmpdir}/a_file"
            target: '/root/a_file'
          $status.should.be.true()
          {$status} = await @incus.file.exists
            container: 'nikita-file-push-2'
            target: '/root/a_file'
          $status.should.be.true()
        try 
          await @clean()
          await @test()
        catch err
          await @clean()
        finally 
          await @clean()

    they 'the same file', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}, registry}) ->
        registry.register 'clean', ->
          await @incus.delete 'nikita-file-push-3', force: true
        await @clean()
        await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'nikita-file-push-3'
          start: true
        await @incus.exec
          $$: retry: 3, sleep: 200 # Wait for network to be ready
          container: 'nikita-file-push-3'
          command: 'apk add openssl'
        await @file
          target: "#{tmpdir}/a_file"
          content: 'something'
        await @incus.file.push
          container: 'nikita-file-push-3'
          source: "#{tmpdir}/a_file"
          target: '/root/a_file'
        {$status} = await @incus.file.push
          container: 'nikita-file-push-3'
          source: "#{tmpdir}/a_file"
          target: '/root/a_file'
        $status.should.be.false()
        await @clean()
  
  describe 'content', ->
    return unless test.tags.incus

    they 'a new file', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          await @incus.delete 'nikita-file-push-4', force: true
        await @clean()
        await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'nikita-file-push-4'
          start: true
        await @incus.exec
          $$: retry: 3, sleep: 200 # Wait for network to be ready
          container: 'nikita-file-push-4'
          command: 'apk add openssl'
        {$status} = await @incus.file.push
          container: 'nikita-file-push-4'
          target: '/root/a_file'
          content: 'something'
        $status.should.be.true()
        {stdout} = await @incus.exec
          container: 'nikita-file-push-4'
          command: 'cat /root/a_file'
        stdout.trim().should.eql 'something'
        await @clean()

    they 'the same file', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          await @incus.delete 'nikita-file-push-5', force: true
        await @clean()
        await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'nikita-file-push-5'
          start: true
        await @incus.exec
          $$: retry: 3, sleep: 200 # Wait for network to be ready
          container: 'nikita-file-push-5'
          command: 'apk add openssl'
        await @incus.file.push
          container: 'nikita-file-push-5'
          target: '/root/a_file'
          content: 'something'
        {$status} = await @incus.file.push
          container: 'nikita-file-push-5'
          target: '/root/a_file'
          content: 'something'
        $status.should.be.false()
        await @clean()
  
  describe 'mode', ->
    return unless test.tags.incus
    
    they 'absolute mode', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          await @incus.delete 'nikita-file-push-6', force: true
        await @clean()
        await @incus.init
          image: "images:#{test.images.alpine}"
          container: 'nikita-file-push-6'
          start: true
        await @incus.exec
          $$: retry: 3, sleep: 200 # Wait for network to be ready
          container: 'nikita-file-push-6'
          command: 'apk add openssl'
        await @incus.file.push
          container: 'nikita-file-push-6'
          target: '/root/a_file'
          content: 'something'
          mode: 700
        {stdout} = await @incus.exec
          container: 'nikita-file-push-6'
          command: 'ls -l /root/a_file'
          trim: true
        stdout.should.match /^-rwx------\s+/
        await @clean()
  
