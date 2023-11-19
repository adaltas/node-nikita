
import nikita from '@nikitajs/core'
import test from './test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'system.tmpfs', ->
  return unless test.tags.system_tmpfs
  
  describe 'generate without merge', ->
    
    they 'simple mount group configuration with target', ({ssh, sudo}) ->
      nikita
        $ssh: ssh
        $sudo: sudo
        $tmpdir: true
      , ({metadata: {tmpdir}}) ->
        {$status} = await @system.tmpfs
          target: "#{tmpdir}/file_1.conf"
          mount: '/var/run/file_1'
          uid: 'root'
          gid: 'root'
          age: '10s'
          argu: '-'
          perm: '0644'
          merge: false
        $status.should.be.true()
        await @execute
          command: 'if [ -d "/var/run/file_1" ] ; then exit 0; else exit 1; fi'
        await @fs.assert
          target: "#{tmpdir}/file_1.conf"
          content: '''
            d /var/run/file_1 0644 root root 10s -
            '''

    they 'status not modified', ({ssh, sudo}) ->
      nikita
        $ssh: ssh
        $sudo: sudo
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        {$status} = await @system.tmpfs
          target: "#{tmpdir}/file_1.conf"
          mount: '/var/run/file_1'
          uid: 'root'
          gid: 'root'
          age: '10s'
          argu: '-'
          perm: '0644'
          merge: false
        $status.should.be.true()
        {$status} = await @system.tmpfs
          target: "#{tmpdir}/file_1.conf"
          mount: '/var/run/file_1'
          uid: 'root'
          gid: 'root'
          age: '10s'
          argu: '-'
          perm: '0644'
          merge: false
        $status.should.be.false()
        await @execute
          command: 'if [ -d "/var/run/file_1" ] ; then exit 0; else exit 1; fi'
        await @fs.assert
          target: "#{tmpdir}/file_1.conf"
          content: '''
            d /var/run/file_1 0644 root root 10s -
            '''
  
    they 'override existing configuration file with target', ({ssh, sudo}) ->
      nikita
        $ssh: ssh
        $sudo: sudo
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        await @fs.remove
          target: "#{tmpdir}/file_1.conf"
        {$status} = await @system.tmpfs
          target: "#{tmpdir}/file_1.conf"
          mount: '/var/run/file_1'
          uid: 'root'
          gid: 'root'
          age: '10s'
          argu: '-'
          perm: '0644'
          merge: false
        $status.should.be.true()
        {$status} = await @system.tmpfs
          target: "#{tmpdir}/file_1.conf"
          mount: '/var/run/file_2'
          uid: 'root'
          gid: 'root'
          age: '10s'
          argu: '-'
          perm: '0644'
          merge: false
        $status.should.be.true()
        await @execute
          command: 'if [ -d "/var/run/file_2" ] ; then exit 0; else exit 1; fi'
        await @fs.assert
          target: "#{tmpdir}/file_1.conf"
          content: '''
            d /var/run/file_2 0644 root root 10s -
            '''
  
  describe 'generate with merge', ->
    
    they 'multiple file with target', ({ssh, sudo}) ->
      nikita
        $ssh: ssh
        $sudo: sudo
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        await @fs.remove
          target: "#{tmpdir}/file_2.conf"
        {$status} = await @system.tmpfs
          target: "#{tmpdir}/file_2.conf"
          mount: '/var/run/file_2'
          uid: 'root'
          gid: 'root'
          age: '10s'
          argu: '-'
          perm: '0644'
          merge: false
        $status.should.be.true()
        {$status} = await @system.tmpfs
          target: "#{tmpdir}/file_2.conf"
          mount: '/var/run/file_1'
          uid: 'root'
          gid: 'root'
          age: '10s'
          argu: '-'
          perm: '0644'
          merge: true
        $status.should.be.true()
        await @execute
          command: 'if [ -d "/var/run/file_1" ] ; then exit 0; else exit 1; fi'
        await @execute
          command: 'if [ -d "/var/run/file_2" ] ; then exit 0; else exit 1; fi'
        await @fs.assert
          target: "#{tmpdir}/file_2.conf"
          content: '''
            d /var/run/file_2 0644 root root 10s -
            d /var/run/file_1 0644 root root 10s -
          '''

    they 'multiple file merge status not modifed with target', ({ssh, sudo}) ->
      nikita
        $ssh: ssh
        $sudo: sudo
        $tmpdir: true
      , ({metadata: {tmpdir}})->
        # await @fs.remove
        #   target: "#{tmpdir}/file_2.conf"
        {$status} = await @system.tmpfs
          target: "#{tmpdir}/file_2.conf"
          mount: '/var/run/file_2'
          uid: 'root'
          gid: 'root'
          age: '10s'
          argu: '-'
          perm: '0644'
          merge: false
        $status.should.be.true()
        {$status} = await @system.tmpfs
          target: "#{tmpdir}/file_2.conf"
          mount: '/var/run/file_1'
          uid: 'root'
          gid: 'root'
          age: '10s'
          argu: '-'
          perm: '0644'
          merge: true
        $status.should.be.true()
        {$status} = await @system.tmpfs
          target: "#{tmpdir}/file_2.conf"
          mount: '/var/run/file_1'
          uid: 'root'
          gid: 'root'
          age: '10s'
          argu: '-'
          perm: '0644'
          merge: true
        $status.should.be.false()
        await @execute
          command: " if [ -d \"/var/run/file_1\" ] ; then exit 0; else exit 1; fi"
        await @execute
          command: " if [ -d \"/var/run/file_2\" ] ; then exit 0; else exit 1; fi"
        await @fs.assert
          target: "#{tmpdir}/file_2.conf"
          content: '''
            d /var/run/file_2 0644 root root 10s -
            d /var/run/file_1 0644 root root 10s -
            '''

  describe 'default target Centos/Redhat 7', ->
    
    they 'simple mount group configuration', ({ssh, sudo}) ->
      nikita
        $ssh: ssh
        $sudo: sudo
      , ->
        await @fs.remove
          target: "/etc/tmpfiles.d/root.conf"
        {$status} = await @system.tmpfs
          mount: '/var/run/file_1'
          uid: 'root'
          gid: 'root'
          age: '10s'
          argu: '-'
          perm: '0644'
          merge: false
        $status.should.be.true()
        await @execute
          command: 'if [ -d "/var/run/file_1" ] ; then exit 0; else exit 1; fi'
        await @fs.assert
          target: '/etc/tmpfiles.d/root.conf'
          content: 'd /var/run/file_1 0644 root root 10s -'

    they 'simple mount group no uid', ({ssh, sudo}) ->
      nikita
        $ssh: ssh
        $sudo: sudo
      , ->
        await @fs.remove '/etc/tmpfiles.d/root.conf'
        {$status} = await @system.tmpfs
          mount: '/var/run/file_1'
          uid: 'root'
          gid: 'root'
          age: '10s'
          argu: '-'
          perm: '0644'
          merge: false
        $status.should.be.true()
        await @execute
          command: 'if [ -d "/var/run/file_1" ] ; then exit 0; else exit 1; fi'
        await @fs.assert
          target: '/etc/tmpfiles.d/root.conf'
          content: 'd /var/run/file_1 0644 root root 10s -'
