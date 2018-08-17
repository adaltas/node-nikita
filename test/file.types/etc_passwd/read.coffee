
nikita = require '../../../src'
test = require '../../test'
they = require 'ssh2-they'

describe 'file.types.etc_passwd.read', ->

  scratch = test.scratch @
  
  they 'shy doesnt modify the status', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/etc/passwd"
      content: """
      root:x:0:0:root:/root:/bin/bash
      bin:x:1:1:bin:/bin:/usr/bin/nologin
      """
    .file.types.etc_passwd.read
      target: "#{scratch}/etc/group"
    , (err, {status}) ->
      status.should.be.false() unless err
    .next (err, {status}) ->
      status.should.be.false() unless err
    .promise()

  they 'activate locales', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/etc/passwd"
      content: """
      root:x:0:0:root:/root:/bin/bash
      bin:x:1:1:bin:/bin:/usr/bin/nologin
      """
    .file.types.etc_passwd.read
      target: "#{scratch}/etc/passwd"
    , (err, {status, users}) ->
      throw err if err
      users.should.eql
        root: user: 'root', uid: 0, gid: 0, comment: 'root', home: '/root', shell: '/bin/bash'
        bin: user: 'bin', uid: 1, gid: 1, comment: 'bin', home: '/bin', shell: '/usr/bin/nologin'
    .promise()
  
  they 'option uid map a username to group record', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/etc/passwd"
      content: """
      root:x:0:root
      bin:x:1:root,bin,daemon
      nobody:x:99:99:nobody:/:/usr/bin/nologin
      """
    .file.types.etc_passwd.read
      target: "#{scratch}/etc/passwd"
      uid: 'nobody'
    , (err, {status, user}) ->
      throw err if err
      user.should.eql user: 'nobody', uid: 99, gid: 99, comment: 'nobody', home: '/', shell: '/usr/bin/nologin'
    .promise()
  
  they 'option uid map a uid to user record', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/etc/passwd"
      content: """
      root:x:0:0:root:/root:/bin/bash
      bin:x:1:1:bin:/bin:/usr/bin/nologin
      nobody:x:99:99:nobody:/:/usr/bin/nologin
      """
    .file.types.etc_passwd.read
      target: "#{scratch}/etc/passwd"
      uid: '99'
    , (err, {status, user}) ->
      throw err if err
      user.should.eql user: 'nobody', uid: 99, gid: 99, comment: 'nobody', home: '/', shell: '/usr/bin/nologin'
    .promise()
  
  they 'option uid throw error if uid dont match any user', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/etc/passwd"
      content: """
      root:x:0:root
      bin:x:1:root,bin,daemon
      """
    .file.types.etc_passwd.read
      target: "#{scratch}/etc/passwd"
      uid: 'nobody'
      relax: true
    , (err) ->
      err.message.should.eql 'Invalid Option: no uid matching "nobody"'
    .file.types.etc_passwd.read
      target: "#{scratch}/etc/passwd"
      uid: '99'
      relax: true
    , (err) ->
      err.message.should.eql 'Invalid Option: no uid matching 99'
    .promise()

  they 'option cache is disabled by default', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/etc/passwd"
      content: """
      root:x:0:0:root:/root:/bin/bash
      bin:x:1:1:bin:/bin:/usr/bin/nologin
      """
    .file.types.etc_passwd.read
      target: "#{scratch}/etc/passwd"
    , (err, {status, users}) ->
      throw err if err
      (@store['nikita:etc_passwd'] is undefined).should.be.true()
    .promise()

  they 'option cache place group in store', (ssh) ->
    logs = []
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/etc/passwd"
      content: """
      root:x:0:0:root:/root:/bin/bash
      bin:x:1:1:bin:/bin:/usr/bin/nologin
      """
    .file.types.etc_passwd.read
      target: "#{scratch}/etc/passwd"
      cache: true
    , (err, {status, users}) ->
      throw err if err
      @store['nikita:etc_passwd'].should.eql users
    .file.types.etc_passwd.read
      log: (log) -> logs.push log
      target: "#{scratch}/etc/passwd"
      cache: true
    , (err, {status, users}) ->
      throw err if err
      logs.some( (log) -> log.message is 'Get passwd definition from cache' ).should.be.true()
    .promise()

  they 'option.log can be true, false, undefined', (ssh) ->
    logs = []
    nikita
      ssh: ssh
    .on 'text', (log) -> logs.push log
    .file
      target: "#{scratch}/etc/passwd"
      content: """
      root:x:0:0:root:/root:/bin/bash
      bin:x:1:1:bin:/bin:/usr/bin/nologin
      """
      log: false
    # Value true enable logs
    .file.types.etc_passwd.read
      target: "#{scratch}/etc/passwd"
      log: true
    , (err) ->
      logs.some( (log) -> log.message is 'Entering fs.readFile').should.be.true() unless err
      logs = []
    # Value undefined disable logs
    .file.types.etc_passwd.read
      target: "#{scratch}/etc/passwd"
      log: undefined
    , (err) ->
      logs.some( (log) -> log.message is 'Entering fs.readFile').should.not.be.true() unless err
    # Value false disable logs
    .file.types.etc_passwd.read
      target: "#{scratch}/etc/passwd"
      log: false
    , (err) ->
      logs.some( (log) -> log.message is 'Entering fs.readFile').should.not.be.true() unless err
    .promise()
      
