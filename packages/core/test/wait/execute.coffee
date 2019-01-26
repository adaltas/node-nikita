
nikita = require '../../src'
{tags, ssh, scratch} = require '../test'
they = require('ssh2-they').configure(ssh)

return unless tags.posix

describe 'wait.execute', ->

  they 'take a single cmd', (ssh) ->
    nikita
      ssh: ssh
    .wait.execute
      cmd: "test -d #{scratch}"
    , (err, {status}) ->
      status.should.be.false()
    .call ->
      setTimeout ->
        nikita(ssh: ssh).fs.mkdir "#{scratch}/a_file", -> # ok
      , 100
    .wait.execute
      cmd: "test -d #{scratch}/a_file"
      interval: 60
    , (err, {status}) ->
      status.should.be.true() unless err
    .promise()

  they 'take a multiple cmds', (ssh) ->
    nikita
      ssh: ssh
    .wait.execute
      cmd: [
        "test -d #{scratch}"
        "test -d #{scratch}"
      ]
    , (err, {status}) ->
      status.should.be.false()
    .call ->
      setTimeout ->
        nikita(ssh: ssh).fs.mkdir "#{scratch}/file_1", -> # ok
        nikita(ssh: ssh).fs.mkdir "#{scratch}/file_2", -> # ok
      , 100
    .wait.execute
      cmd: [
        "test -d #{scratch}/file_1"
        "test -d #{scratch}/file_2"
      ]
      interval: 20
    , (err, {status}) ->
      status.should.be.true() unless err
    .promise()

  describe 'log', ->

    they 'attemps', (ssh) ->
      logs = []
      nikita
        ssh: ssh
      .on 'text', (log) ->
        logs.push "[#{log.level}] #{log.message}" if /Attempt #\d/.test log.message
      .call ->
        setTimeout ->
          nikita(ssh: ssh).fs.mkdir "#{scratch}/a_file", -> # ok
        , 200
      .wait.execute
        cmd: "test -d #{scratch}/a_file"
        interval: 100
      .call ->
        logs.length.should.be.within 2, 4
      .promise()

    they 'honors *_log as true', (ssh) ->
      logs = 0
      nikita
        ssh: ssh
      .on 'stdin', (log) -> logs++
      .on 'stdout', (log) -> logs++
      .on 'stderr', (log) -> logs++
      .wait.execute
        cmd: "echo stdout; echo stderr >&2"
        stdin_log: true
        stdout_log: true
        stderr_log: true
      .call ->
        logs.should.eql 3
      .promise()

    they 'honors *_log as false', (ssh) ->
      logs = 0
      nikita
        ssh: ssh
      .on 'stdin', (log) -> logs++
      .on 'stdout', (log) -> logs++
      .on 'stderr', (log) -> logs++
      .wait.execute
        cmd: "echo stdout; echo stderr >&2"
        stdin_log: false
        stdout_log: false
        stderr_log: false
      .call ->
        logs.should.eql 0
      .promise()

  describe 'quorum', ->

    they 'is not defined', (ssh) ->
      nikita
        ssh: ssh
      .call ->
        setTimeout ->
          nikita(ssh: ssh).fs.mkdir "#{scratch}/file_1", -> # ok
        , 30
        setTimeout ->
          nikita(ssh: ssh).fs.mkdir "#{scratch}/file_2", -> # ok
        , 60
        setTimeout ->
          nikita(ssh: ssh).fs.mkdir "#{scratch}/file_3", -> # ok
        , 90
      .wait.execute
        cmd: [
          "test -d #{scratch}/file_1 && echo 1 >> #{scratch}/result"
          "test -d #{scratch}/file_2 && echo 2 >> #{scratch}/result"
          "test -d #{scratch}/file_3 && echo 3 >> #{scratch}/result"
        ]
        interval: 20
        # quorum: 1
      , (err, {status}) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/result"
        content: '1\n2\n3\n'
      .promise()

    they 'is a number', (ssh) ->
      nikita
        ssh: ssh
      .call ->
        setTimeout ->
          nikita(ssh: ssh).fs.mkdir "#{scratch}/file_1", -> # ok
        , 50
        setTimeout ->
          nikita(ssh: ssh).fs.mkdir "#{scratch}/file_2", -> # ok
        , 100
        setTimeout ->
          nikita(ssh: ssh).fs.mkdir "#{scratch}/file_3", -> # ok
        , 200
      .wait.execute
        cmd: [
          "test -d #{scratch}/file_1 && echo 1 >> #{scratch}/result"
          "test -d #{scratch}/file_2 && echo 2 >> #{scratch}/result"
          "test -d #{scratch}/file_3 && echo 3 >> #{scratch}/result"
        ]
        interval: 20
        quorum: 2
      , (err, {status}) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/result"
        content: '1\n2\n'
      .promise()

    they 'is "true"', (ssh) ->
      nikita
        ssh: ssh
      .call ->
        setTimeout ->
          nikita(ssh: ssh).fs.mkdir "#{scratch}/file_1", -> # ok
        , 30
        setTimeout ->
          nikita(ssh: ssh).fs.mkdir "#{scratch}/file_2", -> # ok
        , 60
        setTimeout ->
          nikita(ssh: ssh).fs.mkdir "#{scratch}/file_3", -> # ok
        , 90
      .wait.execute
        cmd: [
          "test -d #{scratch}/file_1 && echo 1 >> #{scratch}/result"
          "test -d #{scratch}/file_2 && echo 2 >> #{scratch}/result"
          "test -d #{scratch}/file_3 && echo 3 >> #{scratch}/result"
        ]
        interval: 20
        quorum: true
      , (err, {status}) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/result"
        content: '1\n2\n'
      .promise()
