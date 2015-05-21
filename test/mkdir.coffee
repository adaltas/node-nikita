
mecano = require "../src"
misc = require "../src/misc"
path = require 'path'
test = require './test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'mkdir', ->

  scratch = test.scratch @

  they 'should create dir', (ssh, next) ->
    source = "#{scratch}/a_dir"
    mecano
      ssh: ssh
    .mkdir
      directory: source
    , (err, created) ->
      created.should.be.ok
    .mkdir
      directory: source
    , (err, created) ->
      created.should.not.be.ok
    .then next

  they 'should take source if first argument is a string', (ssh, next) ->
    source = "#{scratch}/a_dir"
    mecano
      ssh: ssh
    .mkdir source, (err, created) ->
      created.should.be.ok
    .mkdir source, (err, created) ->
      created.should.not.be.ok
    .then next
  
  they 'should create dir recursively', (ssh, next) ->
    source = "#{scratch}/a_parent_dir/a_dir"
    mecano.mkdir
      ssh: ssh
      directory: source
    , (err, created) ->
      return next err if err
      created.should.be.ok
      next()
  
  they 'should create multiple directories', (ssh, next) ->
    mecano.mkdir
      ssh: ssh
      destination: [
        "#{scratch}/a_parent_dir/a_dir_1"
        "#{scratch}/a_parent_dir/a_dir_2"
      ]
    , (err, created) ->
      return next err if err
      created.should.be.ok
      next()

  describe 'parent', ->

    they 'true set default permissions', (ssh, next) ->
      mecano.mkdir
        ssh: ssh
        destination: [
          "#{scratch}/a_parent_dir/a_dir_1"
          "#{scratch}/a_parent_dir/a_dir_2"
        ]
        parent: true
        mode: 0o717
      , (err, created) ->
        return next err if err
        fs.stat ssh, "#{scratch}/a_parent_dir", (err, stat) ->
          return next err if err
          stat.mode.toString(8).should.not.eql '40717'
          next()

    they 'object set custom permissions', (ssh, next) ->
      mecano.mkdir
        ssh: ssh
        destination: [
          "#{scratch}/a_parent_dir/a_dir_1"
          "#{scratch}/a_parent_dir/a_dir_2"
        ]
        parent: mode: 0o741
        mode: 0o715
      , (err, created) ->
        return next err if err
        fs.stat ssh, "#{scratch}/a_parent_dir", (err, stat) ->
          return next err if err
          stat.mode.toString(8).should.eql '40741'
          fs.stat ssh, "#{scratch}/a_parent_dir/a_dir_1", (err, stat) ->
            return next err if err
            stat.mode.toString(8).should.eql '40715'
            next()

  describe 'exclude', ->
  
    they 'should stop when `exclude` match', (ssh, next) ->
      source = "#{scratch}/a_parent_dir/a_dir/do_not_create_this"
      mecano.mkdir
        ssh: ssh
        directory: source
        exclude: /^do/
      , (err, created) ->
        return next err if err
        created.should.be.ok
        fs.exists ssh, source, (err, created) ->
          created.should.not.be.ok
          source = path.dirname source
          fs.exists ssh, source, (err, created) ->
            created.should.be.ok 
            next()

  describe 'cwd', ->

    they 'should honore `cwd` for relative paths', (ssh, next) ->
      mecano.mkdir
        ssh: ssh
        directory: './a_dir'
        cwd: scratch
      , (err, created) ->
        return next err if err
        created.should.be.ok
        fs.exists ssh, "#{scratch}/a_dir", (err, created) ->
          created.should.be.ok
          next()

  describe 'mode', ->

    they 'change mode as string', (ssh, next) ->
      # 40744: 4 for directory, 744 for permissions
      @timeout 10000
      mecano.mkdir
        ssh: ssh
        directory: "#{scratch}/ssh_dir_string"
        mode: '744'
      , (err, created) ->
        return next err if err
        fs.stat ssh, "#{scratch}/ssh_dir_string", (err, stat) ->
          return next err if err
          stat.mode.toString(8).should.eql '40744'
          next()

    they 'change mode as string', (ssh, next) ->
      # 40744: 4 for directory, 744 for permissions
      @timeout 10000
      mecano.mkdir
        ssh: ssh
        directory: "#{scratch}/ssh_dir_string"
        mode: 0o744
      , (err, created) ->
        return next err if err
        fs.stat ssh, "#{scratch}/ssh_dir_string", (err, stat) ->
          return next err if err
          stat.mode.toString(8).should.eql '40744'
          next()

    they 'detect a permission change', (ssh, next) ->
      # 40744: 4 for directory, 744 for permissions
      @timeout 10000
      mecano
        ssh: ssh
      .mkdir
        directory: "#{scratch}/ssh_dir_string"
        mode: 0o744
      .mkdir
        directory: "#{scratch}/ssh_dir_string"
        mode: 0o755
      , (err, created) ->
        created.should.be.ok
      .mkdir
        directory: "#{scratch}/ssh_dir_string"
        mode: 0o755
      , (err, created) ->
        created.should.not.be.ok
      .then next

    they 'dont ovewrite permission', (ssh, next) ->
      @timeout 10000
      mecano
        ssh: ssh
      .mkdir
        directory: "#{scratch}/a_dir"
        mode: 0o744
      .mkdir
        directory: "#{scratch}/a_dir"
      , (err, created) ->
        created.should.not.be.ok
      .then (err) ->
        return next err if err
        fs.stat ssh, "#{scratch}/a_dir", (err, stat) ->
          return next err if err
          misc.mode.stringify(stat.mode).should.eql '40744'
          next()


