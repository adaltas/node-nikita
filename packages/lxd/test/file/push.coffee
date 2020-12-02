
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.lxd

before () ->
  await nikita
  .execute
    command: "lxc image copy ubuntu:default `lxc remote get-default`:"

describe 'lxd.file.push', ->

  they 'a new file', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @lxd.delete
        container: 'c1'
        force: true
      @lxd.init
        image: 'ubuntu:'
        container: 'c1'
      @lxd.start
        container: 'c1'
      @file
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
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @lxd.delete
        container: 'c1'
        force: true
      @lxd.init
        image: 'ubuntu:'
        container: 'c1'
      @lxd.start
        container: 'c1'
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
          image: 'ubuntu:'
          container: 'c1'
        @lxd.start
          container: 'c1'
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
          image: 'ubuntu:'
          container: 'c1'
        @lxd.start
          container: 'c1'
        @lxd.file.push
          container: 'c1'
          target: '/root/a_file'
          content: 'something'
        {status} = await @lxd.file.push
          container: 'c1'
          target: '/root/a_file'
          content: 'something'
        status.should.be.false()
    
