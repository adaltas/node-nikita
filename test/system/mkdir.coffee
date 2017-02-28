
mecano = require '../../src'
misc = require '../../src/misc'
path = require 'path'
test = require '../test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'system.mkdir', ->

  scratch = test.scratch @

  they 'as a directory option or as a string', (ssh, next) ->
    mecano
      ssh: ssh
    .system.mkdir directory: "#{scratch}/a_dir", (err, created) ->
      created.should.be.true()
    .system.mkdir directory: "#{scratch}/a_dir", (err, created) ->
      created.should.be.false()
    .system.mkdir "#{scratch}/b_dir", (err, created) ->
      created.should.be.true()
    .system.mkdir "#{scratch}/b_dir", (err, created) ->
      created.should.be.false()
    .then next

  they 'should take source if first argument is a string', (ssh, next) ->
    source = "#{scratch}/a_dir"
    mecano
      ssh: ssh
    .system.mkdir source, (err, created) ->
      created.should.be.true()
    .system.mkdir source, (err, created) ->
      created.should.be.false()
    .then next
  
  they 'should create dir recursively', (ssh, next) ->
    mecano
      ssh: ssh
    .system.mkdir
      directory: "#{scratch}/a_parent_dir_1/a_dir"
    , (err, created) ->
      created.should.be.true() unless err
    .system.mkdir
      directory: "#{scratch}/a_parent_dir_2/a_dir/"
    , (err, created) ->
      created.should.be.true() unless err
    .then next
  
  they 'should create multiple directories', (ssh, next) ->
    mecano.system.mkdir
      ssh: ssh
      target: [
        "#{scratch}/a_parent_dir/a_dir_1"
        "#{scratch}/a_parent_dir/a_dir_2"
      ]
    , (err, created) ->
      return next err if err
      created.should.be.true()
      next()

  describe 'parent', ->

    they 'true set default permissions', (ssh, next) ->
      mecano.system.mkdir
        ssh: ssh
        target: [
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
      mecano.system.mkdir
        ssh: ssh
        target: [
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
      mecano.system.mkdir
        ssh: ssh
        directory: source
        exclude: /^do/
      , (err, created) ->
        return next err if err
        created.should.be.true()
        fs.exists ssh, source, (err, created) ->
          created.should.be.false()
          source = path.dirname source
          fs.exists ssh, source, (err, created) ->
            created.should.be.true() 
            next()

  describe 'cwd', ->

    they 'should honore `cwd` for relative paths', (ssh, next) ->
      mecano.system.mkdir
        ssh: ssh
        directory: './a_dir'
        cwd: scratch
      , (err, created) ->
        return next err if err
        created.should.be.true()
        fs.exists ssh, "#{scratch}/a_dir", (err, created) ->
          created.should.be.true()
          next()

  describe 'mode', ->

    they 'change mode as string', (ssh, next) ->
      # 40744: 4 for directory, 744 for permissions
      @timeout 10000
      mecano.system.mkdir
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
      mecano.system.mkdir
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
      .system.mkdir
        directory: "#{scratch}/ssh_dir_string"
        mode: 0o744
      .system.mkdir
        directory: "#{scratch}/ssh_dir_string"
        mode: 0o755
      , (err, created) ->
        created.should.be.true()
      .system.mkdir
        directory: "#{scratch}/ssh_dir_string"
        mode: 0o755
      , (err, created) ->
        created.should.be.false()
      .then next

    they 'dont ovewrite permission', (ssh, next) ->
      @timeout 10000
      mecano
        ssh: ssh
      .system.mkdir
        directory: "#{scratch}/a_dir"
        mode: 0o744
      .system.mkdir
        directory: "#{scratch}/a_dir"
      , (err, created) ->
        created.should.be.false()
      .then (err) ->
        return next err if err
        fs.stat ssh, "#{scratch}/a_dir", (err, stat) ->
          return next err if err
          misc.mode.stringify(stat.mode).should.eql '40744'
          next()
