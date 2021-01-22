
nikita = require '../../../src'
{tags, config} = require '../../test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'actions.execute.wait', ->

  they 'take a single command', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {status} = await @execute.wait
        command: "test -d #{tmpdir}"
      status.should.be.false()
      @call ->
        setTimeout ->
          nikita(ssh: ssh?.config).fs.mkdir "#{tmpdir}/a_file"
        , 100
      {status} = await @execute.wait
        command: "test -d #{tmpdir}/a_file"
        interval: 60
      status.should.be.true()

  they 'take a multiple commands', ({ssh}) ->
    nikita
      ssh: ssh
      metadata: tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {status} = await @execute.wait
        command: [
          "test -d #{tmpdir}"
          "test -d #{tmpdir}"
        ]
      status.should.be.false()
      @call ->
        setTimeout ->
          nikita(ssh: ssh?.config).fs.mkdir "#{tmpdir}/file_1"
          nikita(ssh: ssh?.config).fs.mkdir "#{tmpdir}/file_2"
        , 100
      {status} = await @execute.wait
        command: [
          "test -d #{tmpdir}/file_1"
          "test -d #{tmpdir}/file_2"
        ]
        interval: 20
      status.should.be.true()

  describe 'log', ->

    they 'attemps', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        logs = []
        @call ->
          setTimeout ->
            nikita(ssh: ssh?.config).fs.mkdir "#{tmpdir}/a_file"
          , 200
        @execute.wait
          command: "test -d #{tmpdir}/a_file"
          interval: 100
          metadata: log: ({log}) ->
            logs.push log if /Attempt #\d/.test log.message
        @call ->
          logs.length.should.be.within 2, 8

    they 'honors *_log as true', ({ssh}) ->
      nikita
        ssh: ssh
      , ->
        logs = 0
        @execute.wait
          command: "echo stdout; echo stderr >&2"
          stdin_log: true
          stdout_log: true
          stderr_log: true
          metadata: log: ({log}) ->
            logs++ if log.type in ['stdin', 'stdout', 'stderr']
        @call ->
          logs.should.eql 3

    they 'honors *_log as false', ({ssh}) ->
      nikita
        ssh: ssh
      , ->
        logs = 0
        @execute.wait
          command: "echo stdout; echo stderr >&2"
          stdin_log: false
          stdout_log: false
          stderr_log: false
          metadata: log: ({log}) ->
            logs++ if log.type in ['stdin', 'stdout', 'stderr']
        @call ->
          logs.should.eql 0

  describe 'quorum', ->

    they 'is not defined', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @call ->
          setTimeout ->
            nikita(ssh: ssh?.config).fs.mkdir "#{tmpdir}/file_1"
          , 30
          setTimeout ->
            nikita(ssh: ssh?.config).fs.mkdir "#{tmpdir}/file_2"
          , 60
          setTimeout ->
            nikita(ssh: ssh?.config).fs.mkdir "#{tmpdir}/file_3"
          , 90
        {status} = await @execute.wait
          command: [
            "test -d #{tmpdir}/file_1 && echo 1 >> #{tmpdir}/result"
            "test -d #{tmpdir}/file_2 && echo 2 >> #{tmpdir}/result"
            "test -d #{tmpdir}/file_3 && echo 3 >> #{tmpdir}/result"
          ]
          interval: 20
          # quorum: 1
        status.should.be.true()
        @fs.assert
          target: "#{tmpdir}/result"
          content: '1\n2\n3\n'

    they 'is a number', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @call ->
          setTimeout ->
            nikita(ssh: ssh?.config).fs.mkdir "#{tmpdir}/file_1"
          , 100
          setTimeout ->
            nikita(ssh: ssh?.config).fs.mkdir "#{tmpdir}/file_2"
          , 200
          setTimeout ->
            nikita(ssh: ssh?.config).fs.mkdir "#{tmpdir}/file_3"
          , 300
        {status} = await @execute.wait
          command: [
            "test -d #{tmpdir}/file_1 && echo 1 >> #{tmpdir}/result"
            "test -d #{tmpdir}/file_2 && echo 2 >> #{tmpdir}/result"
            "test -d #{tmpdir}/file_3 && echo 3 >> #{tmpdir}/result"
          ]
          interval: 20
          quorum: 2
        status.should.be.true()
        @fs.assert
          target: "#{tmpdir}/result"
          content: '1\n2\n'

    they 'is "true"', ({ssh}) ->
      nikita
        ssh: ssh
        metadata: tmpdir: true
      , ({metadata: {tmpdir}}) ->
        @call ->
          setTimeout ->
            nikita(ssh: ssh?.config).fs.mkdir "#{tmpdir}/file_1"
          , 30
          setTimeout ->
            nikita(ssh: ssh?.config).fs.mkdir "#{tmpdir}/file_2"
          , 60
          setTimeout ->
            nikita(ssh: ssh?.config).fs.mkdir "#{tmpdir}/file_3"
          , 90
        {status} = await @execute.wait
          command: [
            "test -d #{tmpdir}/file_1 && echo 1 >> #{tmpdir}/result"
            "test -d #{tmpdir}/file_2 && echo 2 >> #{tmpdir}/result"
            "test -d #{tmpdir}/file_3 && echo 3 >> #{tmpdir}/result"
          ]
          interval: 20
          quorum: true
        status.should.be.true()
        @fs.assert
          target: "#{tmpdir}/result"
          content: '1\n2\n'
