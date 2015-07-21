
mecano = require "../src"
test = require './test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'wait_execute', ->

  scratch = test.scratch @

  they 'take a single cmd', (ssh, next) ->
    mecano
      ssh: ssh
    .wait_execute
      cmd: "test -d #{scratch}"
    , (err, status) ->
      status.should.be.false()
    .call ->
      setTimeout ->
        fs.mkdir ssh, "#{scratch}/a_file", -> # ok
      , 100
    .wait_execute
      cmd: "test -d #{scratch}/a_file"
      interval: 60
    , (err, status) ->
      status.should.be.true()
    .then next

  they 'take a multiple cmds', (ssh, next) ->
    mecano
      ssh: ssh
    .wait_execute
      cmd: [
        "test -d #{scratch}"
        "test -d #{scratch}"
      ]
    , (err, status) ->
      status.should.be.false()
    .call ->
      setTimeout ->
        fs.mkdir ssh, "#{scratch}/file_1", -> # ok
        fs.mkdir ssh, "#{scratch}/file_2", -> # ok
      , 100
    .wait_execute
      cmd: [
        "test -d #{scratch}/file_1"
        "test -d #{scratch}/file_2"
      ]
      interval: 20
    , (err, status) ->
      status.should.be.true()
    .then next

  describe 'log', ->

    they 'attemps', (ssh, next) ->
      logs = []
      mecano
        ssh: ssh
      .call ->
        setTimeout ->
          fs.mkdir ssh, "#{scratch}/a_file", -> # ok
        , 100
      .wait_execute
        cmd: "test -d #{scratch}/a_file"
        interval: 60
        log: (msg) -> logs.push msg if /attempt/.test msg
      .then (err) ->
        return next err if err
        logs.should.eql [
          'mecano `wait_execute`: attempt #1 [INFO]'
          'mecano `wait_execute`: attempt #2 [INFO]'
          'mecano `wait_execute`: attempt #3 [INFO]'
        ]
        next()

  describe 'quorum', ->

    they 'is not defined', (ssh, next) ->
      mecano
        ssh: ssh
      .call ->
        setTimeout ->
          fs.mkdir ssh, "#{scratch}/file_1", -> # ok
        , 30
        setTimeout ->
          fs.mkdir ssh, "#{scratch}/file_2", -> # ok
        , 60
        setTimeout ->
          fs.mkdir ssh, "#{scratch}/file_3", -> # ok
        , 90
      .wait_execute
        cmd: [
          "test -d #{scratch}/file_1 && echo 1 >> #{scratch}/result"
          "test -d #{scratch}/file_2 && echo 2 >> #{scratch}/result"
          "test -d #{scratch}/file_3 && echo 3 >> #{scratch}/result"
        ]
        interval: 20
        # quorum: 1
      , (err, status) ->
        status.should.be.true()
      .then (err) ->
        return next err if err
        fs.readFile ssh, "#{scratch}/result", 'ascii', (err, data) ->
          data.should.eql '1\n2\n3\n' unless err
          next err

    they 'is a number', (ssh, next) ->
      mecano
        ssh: ssh
      .call ->
        setTimeout ->
          fs.mkdir ssh, "#{scratch}/file_1", -> # ok
        , 30
        setTimeout ->
          fs.mkdir ssh, "#{scratch}/file_2", -> # ok
        , 60
        setTimeout ->
          fs.mkdir ssh, "#{scratch}/file_3", -> # ok
        , 90
      .wait_execute
        cmd: [
          "test -d #{scratch}/file_1 && echo 1 >> #{scratch}/result"
          "test -d #{scratch}/file_2 && echo 2 >> #{scratch}/result"
          "test -d #{scratch}/file_3 && echo 3 >> #{scratch}/result"
        ]
        interval: 20
        quorum: 2
      , (err, status) ->
        status.should.be.true()
      .then (err) ->
        return next err if err
        fs.readFile ssh, "#{scratch}/result", 'ascii', (err, data) ->
          data.should.eql '1\n2\n' unless err
          next err

    they 'is "true"', (ssh, next) ->
      mecano
        ssh: ssh
      .call ->
        setTimeout ->
          fs.mkdir ssh, "#{scratch}/file_1", -> # ok
        , 30
        setTimeout ->
          fs.mkdir ssh, "#{scratch}/file_2", -> # ok
        , 60
        setTimeout ->
          fs.mkdir ssh, "#{scratch}/file_3", -> # ok
        , 90
      .wait_execute
        cmd: [
          "test -d #{scratch}/file_1 && echo 1 >> #{scratch}/result"
          "test -d #{scratch}/file_2 && echo 2 >> #{scratch}/result"
          "test -d #{scratch}/file_3 && echo 3 >> #{scratch}/result"
        ]
        interval: 20
        quorum: true
      , (err, status) ->
        status.should.be.true()
      .then (err) ->
        return next err if err
        fs.readFile ssh, "#{scratch}/result", 'ascii', (err, data) ->
          data.should.eql '1\n2\n' unless err
          next err







