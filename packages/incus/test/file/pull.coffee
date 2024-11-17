
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

## Todo

# - Test about the mode
# - Test about pulling a file that already exists in local directory

## Tests

describe 'incus.file.pull', ->
  return unless test.tags.incus

  they 'require openssl', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @incus.delete 'nikita-file-pull-1', force: true
      registry.register 'test', ->
        await @incus.init
            image: "images:#{test.images.alpine}"
            container: 'nikita-file-pull-1'
            start: true
        await @incus.start 'nikita-file-pull-1'
        # pulling file from container
        await @incus.file.pull
          container: 'nikita-file-pull-1'
          source: "/root/file.sh"
          target: "#{tmpdir}"
        .should.be.rejectedWith
          code: 'NIKITA_LXD_FILE_PULL_MISSING_OPENSSL'
      try
          await @clean()
          await @test()
        catch err
          await @clean()
        finally
          await @clean()

  they 'should pull a file from a remote server', ({ssh})  ->
    @timeout -1
    nikita
        $ssh: ssh
        $tmpdir: true
      , ({metadata: {tmpdir}, registry}) ->
        await registry.register 'clean', ->
          await @incus.delete 'nikita-file-pull-2', force: true
          await @incus.network.delete 'nktincuspub'
        await registry.register 'test', ->
          # creating network
          await @incus.network 'nktincuspub', properties:
            'ipv4.address': '10.10.40.1/24'
            'ipv4.nat': true
            'ipv6.address': 'none'
          # creating a container
          await @incus.init
            image: "images:#{test.images.alpine}"
            container: 'nikita-file-pull-2'
            nic:
              eth0:
                name: 'eth0', nictype: 'bridged', parent: 'nktincuspub'
            ssh: enabled: true
            start: true
          # attaching network
          await @incus.network.attach
            container: 'nikita-file-pull-2'
            name: 'nktincuspub'
          # adding openssl for file pull
          await @incus.exec
            $retry: 100
            $wait: 200 # Wait for network to be ready
            container: 'nikita-file-pull-2'
            command: 'apk add openssl'
          await @incus.exec
            container: 'nikita-file-pull-2'
            command: "touch file.sh && echo 'hello' > file.sh"
          # pulling file from container
          await @incus.file.pull
            container: 'nikita-file-pull-2'
            source: "/root/file.sh"
            target: "#{tmpdir}/"
          # check if file exists in temp directory
          {exists} = await @fs.exists
            target: "#{tmpdir}/file.sh"
          exists.should.be.eql true
        try
          await @clean()
          await @test()
        catch err
          await @clean()
        finally
          await @clean()
