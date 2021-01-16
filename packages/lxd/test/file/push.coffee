
nikita = require '@nikitajs/engine/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.lxd

describe 'lxd.file.push', ->
  
  they 'require openssl', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @lxd.delete
        container: 'c1'
        force: true
      await @lxd.init
        image: 'images:alpine/edge'
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
        image: 'images:alpine/edge'
        container: 'c1'
      await @lxd.start
        container: 'c1'
      await @wait 300 # Wait for network to be ready
      await @lxd.exec
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
        image: 'images:alpine/edge'
        container: 'c1'
      @lxd.start
        container: 'c1'
      await @wait 300 # Wait for network to be ready
      @lxd.exec
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

    they 'a new file', ({ssh}) ->
      nikita
        ssh: ssh
      , ->
        @lxd.delete
          container: 'c1'
          force: true
        @lxd.init
          image: 'images:alpine/edge'
          container: 'c1'
        @lxd.start
          container: 'c1'
        await @wait 300 # Wait for network to be ready
        @lxd.exec
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
          image: 'images:alpine/edge'
          container: 'c1'
        @lxd.start
          container: 'c1'
        await @wait 300 # Wait for network to be ready
        @lxd.exec
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
    
