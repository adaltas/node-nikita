
nikita = require '@nikitajs/core/lib'
{config, images, tags} = require '../test'
they = require('mocha-they')(config)

describe 'lxd.file.push', ->
  
  describe 'schema', ->
    return unless tags.api

    it 'mode symbolic', ->
      nikita.lxd.file.push
        container: 'c1'
        target: '/root/a_file'
        content: 'something'
        mode: 'u=rwx'
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'

    it 'mode coercion', ->
      nikita.lxd.file.push
        container: 'c1'
        target: '/root/a_file'
        content: 'something'
        mode: '700'
      , ({config}) ->
        config.mode.should.eql 0o0700
  
  describe 'usage', ->
    return unless tags.lxd
    
    they 'require openssl', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @lxd.delete
          container: 'c1'
          force: true
        await @lxd.init
          image: "images:#{images.alpine}"
          container: 'c1'
        await @lxd.start
          container: 'c1'
        await @file.touch
          target: "#{tmpdir}/a_file"
        @lxd.file.push
          container: 'c1'
          source: "#{tmpdir}/a_file"
          target: '/root/a_file'
        .should.be.rejectedWith
          code: 'NIKITA_LXD_FILE_PUSH_MISSING_OPENSSL'

    they 'a new file', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        await @lxd.delete
          container: 'c1'
          force: true
        await @lxd.init
          image: "images:#{images.alpine}"
          container: 'c1'
        await @lxd.start
          container: 'c1'
        await @lxd.exec
          metadata: # Wait for network to be ready
            retry: 3
            sleep: 200
          container: 'c1'
          command: 'apk add openssl'
        await @file
          target: "#{tmpdir}/a_file"
          content: 'something'
        {status} = await @lxd.file.push
          container: 'c1'
          source: "#{tmpdir}/a_file"
          target: '/root/a_file'
        status.should.be.true()
        {status} = await @lxd.file.exists
          container: 'c1'
          target: '/root/a_file'
        status.should.be.true()

    they 'the same file', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @lxd.delete
          container: 'c1'
          force: true
        @lxd.init
          image: "images:#{images.alpine}"
          container: 'c1'
        @lxd.start
          container: 'c1'
        await @lxd.exec
          metadata: # Wait for network to be ready
            retry: 3
            sleep: 200
          container: 'c1'
          command: 'apk add openssl'
        @file
          target: "#{tmpdir}/a_file"
          content: 'something'
        @lxd.file.push
          container: 'c1'
          source: "#{tmpdir}/a_file"
          target: '/root/a_file'
        {status} = await @lxd.file.push
          container: 'c1'
          source: "#{tmpdir}/a_file"
          target: '/root/a_file'
        status.should.be.false()
  
  describe 'content', ->
    return unless tags.lxd

    they 'a new file', ({ssh}) ->
      nikita
        ssh: ssh
      , ->
        @lxd.delete
          container: 'c1'
          force: true
        @lxd.init
          image: "images:#{images.alpine}"
          container: 'c1'
        @lxd.start
          container: 'c1'
        await @lxd.exec
          metadata: # Wait for network to be ready
            retry: 3
            sleep: 200
          container: 'c1'
          command: 'apk add openssl'
        {status} = await @lxd.file.push
          container: 'c1'
          target: '/root/a_file'
          content: 'something'
        status.should.be.true()
        {stdout} = await @lxd.exec
          container: 'c1'
          command: 'cat /root/a_file'
        stdout.trim().should.eql 'something'

    they 'the same file', ({ssh}) ->
      nikita
        ssh: ssh
      , ->
        @lxd.delete
          container: 'c1'
          force: true
        @lxd.init
          image: "images:#{images.alpine}"
          container: 'c1'
        @lxd.start
          container: 'c1'
        await @lxd.exec
          metadata: # Wait for network to be ready
            retry: 3
            sleep: 200
          container: 'c1'
          command: 'apk add openssl'
        @lxd.file.push
          container: 'c1'
          target: '/root/a_file'
          content: 'something'
        {status} = await @lxd.file.push
          container: 'c1'
          target: '/root/a_file'
          content: 'something'
        status.should.be.false()
  
  describe 'mode', ->
    return unless tags.lxd
    
    they 'absolute mode', ({ssh}) ->
      nikita
        ssh: ssh
      , ->
        @lxd.delete
          container: 'c1'
          force: true
        @lxd.init
          image: "images:#{images.alpine}"
          container: 'c1'
        @lxd.start
          container: 'c1'
        @lxd.exec
          metadata: # Wait for network to be ready
            retry: 3
            sleep: 200
          container: 'c1'
          command: 'apk add openssl'
        @lxd.file.push
          container: 'c1'
          target: '/root/a_file'
          content: 'something'
          mode: 700
        {stdout} = await @lxd.exec
          container: 'c1'
          command: 'ls -l /root/a_file'
          trim: true
        stdout.should.match /^-rwx------\s+/
  
