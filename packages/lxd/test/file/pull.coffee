
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

## Todo

# - Test about the mode
# - Test about pulling a file that already exists in local directory

## Tests

describe 'lxc.file.pull', ->
  return unless test.tags.lxd
    
  they 'require openssl', ({ssh}) ->
    nikita
      $ssh: ssh
    , ({registry}) ->
      registry.register 'clean', ->
        @lxc.delete 'nikita-file-pull-1', force: true
      registry.register 'test', ->
        await @lxc.init
            image: "images:#{test.images.alpine}"
            container: 'nikita-file-pull-1'
            start: true
        await @lxc.start 'nikita-file-pull-1'
        # pulling file from container
        await @lxc.file.pull
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
          await @lxc.delete 
            container: 'nikita-file-pull-2'
            force: true
          await @lxc.network.delete
            network: 'nktlxdpub'
        await registry.register 'test', ->
          # creating network
          await @lxc.network
            network: 'nktlxdpub'
            properties:
              'ipv4.address': '10.10.40.1/24'
              'ipv4.nat': true
              'ipv6.address': 'none'
          # creating a container
          await @lxc.init
            image: "images:#{test.images.alpine}"
            container: 'nikita-file-pull-2'
            nic:
              eth0:
                name: 'eth0', nictype: 'bridged', parent: 'nktlxdpub'
            ssh: enabled: true
            start: true
          # attaching network
          await @lxc.network.attach
            container: 'nikita-file-pull-2'
            network: 'nktlxdpub'
          # adding openssl for file pull
          await @lxc.exec
            $retry: 100
            $wait: 200 # Wait for network to be ready
            container: 'nikita-file-pull-2'
            command: 'apk add openssl'
          await @lxc.exec
            container: 'nikita-file-pull-2'
            command: "touch file.sh && echo 'hello' > file.sh"
          # pulling file from container
          await @lxc.file.pull
            container: 'nikita-file-pull-2'
            source: "/root/file.sh"
            target: "#{tmpdir}/"
          # check if file exists in temp directory
          {exists} = await @fs.base.exists
            target: "#{tmpdir}/file.sh"
          exists.should.be.eql true
        try 
          await @clean()
          await @test()
        catch err
          await @clean()
        finally 
          await @clean()
