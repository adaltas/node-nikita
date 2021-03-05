
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
        $ssh: ssh
        $tmpdir: true
      , ({registry}) ->
        registry.register 'clean', ->
          @lxd.delete 'nikita-file-push-1', force: true
        await @clean()
        await @lxd.init
          image: "images:#{images.alpine}"
          container: 'nikita-file-push-1'
        await @lxd.start
          container: 'nikita-file-push-1'
        await @file.touch
          target: "#{tmpdir}/a_file"
        @lxd.file.push
          container: 'nikita-file-push-1'
          source: "#{tmpdir}/a_file"
          target: '/root/a_file'
        .should.be.rejectedWith
          code: 'NIKITA_LXD_FILE_PUSH_MISSING_OPENSSL'
        await @clean()

    they 'a new file', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({registry}) ->
        registry.register 'clean', ->
          @lxd.delete 'nikita-file-push-2', force: true
        await @clean()
        await @lxd.init
          image: "images:#{images.alpine}"
          container: 'nikita-file-push-2'
        await @lxd.start
          container: 'nikita-file-push-2'
        await @lxd.exec
          $$: retry: 3, sleep: 200 # Wait for network to be ready
          container: 'nikita-file-push-2'
          command: 'apk add openssl'
        await @file
          target: "#{tmpdir}/a_file"
          content: 'something'
        {$status} = await @lxd.file.push
          container: 'nikita-file-push-2'
          source: "#{tmpdir}/a_file"
          target: '/root/a_file'
        $status.should.be.true()
        {$status} = await @lxd.file.exists
          container: 'nikita-file-push-2'
          target: '/root/a_file'
        $status.should.be.true()
        await @clean()

    they 'the same file', ({ssh}) ->
      nikita
        $ssh: ssh
        $tmpdir: true
      , ({registry}) ->
        registry.register 'clean', ->
          @lxd.delete 'nikita-file-push-3', force: true
        await @clean()
        @lxd.init
          image: "images:#{images.alpine}"
          container: 'nikita-file-push-3'
        @lxd.start
          container: 'nikita-file-push-3'
        await @lxd.exec
          $$: retry: 3, sleep: 200 # Wait for network to be ready
          container: 'nikita-file-push-3'
          command: 'apk add openssl'
        @file
          target: "#{tmpdir}/a_file"
          content: 'something'
        @lxd.file.push
          container: 'nikita-file-push-3'
          source: "#{tmpdir}/a_file"
          target: '/root/a_file'
        {$status} = await @lxd.file.push
          container: 'nikita-file-push-3'
          source: "#{tmpdir}/a_file"
          target: '/root/a_file'
        $status.should.be.false()
        await @clean()
  
  describe 'content', ->
    return unless tags.lxd

    they 'a new file', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          @lxd.delete 'nikita-file-push-4', force: true
        await @clean()
        @lxd.init
          image: "images:#{images.alpine}"
          container: 'nikita-file-push-4'
        @lxd.start
          container: 'nikita-file-push-4'
        await @lxd.exec
          $$: retry: 3, sleep: 200 # Wait for network to be ready
          container: 'nikita-file-push-4'
          command: 'apk add openssl'
        {$status} = await @lxd.file.push
          container: 'nikita-file-push-4'
          target: '/root/a_file'
          content: 'something'
        $status.should.be.true()
        {stdout} = await @lxd.exec
          container: 'nikita-file-push-4'
          command: 'cat /root/a_file'
        stdout.trim().should.eql 'something'
        await @clean()

    they 'the same file', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          @lxd.delete 'nikita-file-push-5', force: true
        await @clean()
        @lxd.init
          image: "images:#{images.alpine}"
          container: 'nikita-file-push-5'
        @lxd.start
          container: 'nikita-file-push-5'
        await @lxd.exec
          $$: retry: 3, sleep: 200 # Wait for network to be ready
          container: 'nikita-file-push-5'
          command: 'apk add openssl'
        @lxd.file.push
          container: 'nikita-file-push-5'
          target: '/root/a_file'
          content: 'something'
        {$status} = await @lxd.file.push
          container: 'nikita-file-push-5'
          target: '/root/a_file'
          content: 'something'
        $status.should.be.false()
        await @clean()
  
  describe 'mode', ->
    return unless tags.lxd
    
    they 'absolute mode', ({ssh}) ->
      nikita
        $ssh: ssh
      , ({registry}) ->
        registry.register 'clean', ->
          @lxd.delete 'nikita-file-push-6', force: true
        await @clean()
        @lxd.init
          image: "images:#{images.alpine}"
          container: 'nikita-file-push-6'
        @lxd.start
          container: 'nikita-file-push-6'
        @lxd.exec
          $$: retry: 3, sleep: 200 # Wait for network to be ready
          container: 'nikita-file-push-6'
          command: 'apk add openssl'
        @lxd.file.push
          container: 'nikita-file-push-6'
          target: '/root/a_file'
          content: 'something'
          mode: 700
        {stdout} = await @lxd.exec
          container: 'nikita-file-push-6'
          command: 'ls -l /root/a_file'
          trim: true
        stdout.should.match /^-rwx------\s+/
        await @clean()
  
