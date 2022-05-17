
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require '../test'
they = require('mocha-they')(config)

## Todo

# - Test about the mode
# - Test about pulling a file that already exists in local directory

## Tests

describe 'lxc.file.pull', ->

  describe 'usage', ->
    return unless tags.lxd
    
    they 'require openssl', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          @lxc.delete 'nikita-file-pull-1', force: true
        registry.register 'test', ->
          await @lxc.init
              image: "images:#{images.alpine}"
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
          cluster =
            networks:
              nktlxdpub:
                'ipv4.address': '10.10.40.1/24'
                'ipv4.nat': true
                'ipv6.address': 'none'
            containers:
              'nikita-file-pull-2':
                image: 'images:centos/7'
                nic:
                  eth0:
                    name: 'eth0', nictype: 'bridged', parent: 'nktlxdpub'
                ssh: enabled: true
          await registry.register 'clean', ->
            await @lxc.cluster.delete {...cluster, force: true}
          await registry.register 'test', ->
            # creating a cluster of a singular container
            await @lxc.cluster cluster
            # creating a file
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
