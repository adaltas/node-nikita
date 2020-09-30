
nikita = require '@nikitajs/engine/src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure ssh

return unless tags.lxd

describe 'lxd.file.push', ->

  they 'a new file', ({ssh}) ->
    nikita
      ssh: ssh
    .lxd.delete
      container: 'c1'
      force: true
    .lxd.init
      image: 'ubuntu:18.04'
      container: 'c1'
    .lxd.start
      container: 'c1'
    .file
      target: "#{scratch}/a_file"
      content: 'something'
    .lxd.file.push
      container: 'c1'
      source: "#{scratch}/a_file"
      target: '/root/a_file'
    , (err, {status}) ->
      status.should.be.true()
    .lxd.file.exists
      container: 'c1'
      target: '/root/a_file'
    , (err, {status}) ->
      status.should.be.true()
    .promise()

  they 'the same file', ({ssh}) ->
    nikita
      ssh: ssh
    .lxd.delete
      container: 'c1'
      force: true
    .lxd.init
      image: 'ubuntu:18.04'
      container: 'c1'
    .lxd.start
      container: 'c1'
    .file
      target: "#{scratch}/a_file"
      content: 'something'
    .lxd.file.push
      container: 'c1'
      source: "#{scratch}/a_file"
      target: '/root/a_file'
    .lxd.file.push
      container: 'c1'
      source: "#{scratch}/a_file"
      target: '/root/a_file'
    , (err, {status}) ->
      status.should.be.false()
    .promise()

  describe 'content', ->

    they 'a new file', ({ssh}) ->
      nikita
        ssh: ssh
      .lxd.delete
        container: 'c1'
        force: true
      .lxd.init
        image: 'ubuntu:18.04'
        container: 'c1'
      .lxd.start
        container: 'c1'
      .lxd.file.push
        container: 'c1'
        target: '/root/a_file'
        content: 'something'
      , (err, {status}) ->
        status.should.be.true()
      .lxd.exec
        container: 'c1'
        cmd: 'cat /root/a_file'
      , (err, {stdout}) ->
        stdout.trim().should.eql 'something'
      .promise()

    they 'the same file', ({ssh}) ->
      nikita
        ssh: ssh
      .lxd.delete
        container: 'c1'
        force: true
      .lxd.init
        image: 'ubuntu:18.04'
        container: 'c1'
      .lxd.start
        container: 'c1'
      .lxd.file.push
        container: 'c1'
        target: '/root/a_file'
        content: 'something'
      .lxd.file.push
        container: 'c1'
        target: '/root/a_file'
        content: 'something'
      , (err, {status}) ->
        status.should.be.false()
      .promise()
