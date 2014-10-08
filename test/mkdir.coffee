
lib = if process.env.MECANO_COV then 'lib-cov' else 'lib'
mecano = require "../#{lib}"
misc = require "../#{lib}/misc"
fs = require 'fs'
path = require 'path'
fs.exists ?= path.exists
test = require './test'
they = require 'ssh2-they'
fs = require 'ssh2-fs'

describe 'mkdir', ->

  scratch = test.scratch @

  they 'should create dir', (ssh, next) ->
    source = "#{scratch}/a_dir"
    mecano.mkdir
      ssh: ssh
      directory: source
    , (err, created) ->
      return next err if err
      created.should.be.ok
      mecano.mkdir
        ssh: ssh
        directory: source
      , (err, created) ->
        return next err if err
        created.should.not.be.ok
        next()

  it 'should take source if first argument is a string', (next) ->
    source = "#{scratch}/a_dir"
    mecano.mkdir source, (err, created) ->
      return next err if err
      created.should.be.ok
      mecano.mkdir source, (err, created) ->
        return next err if err
        created.should.not.be.ok
        next()
  
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
      mecano.mkdir
        ssh: ssh
        directory: "#{scratch}/ssh_dir_string"
        mode: 0o744
      , (err, created) ->
        return next err if err
        mecano.mkdir
          ssh: ssh
          directory: "#{scratch}/ssh_dir_string"
          mode: 0o755
        , (err, created) ->
          return next err if err
          created.should.be.ok
          mecano.mkdir
            ssh: ssh
            directory: "#{scratch}/ssh_dir_string"
            mode: 0o755
          , (err, created) ->
            return next err if err
            created.should.not.be.ok
            next()

    they 'dont ovewrite permission', (ssh, next) ->
      @timeout 10000
      mecano.mkdir
        ssh: ssh
        directory: "#{scratch}/a_dir"
        mode: 0o744
      , (err, created) ->
        return next err if err
        mecano.mkdir
          ssh: ssh
          directory: "#{scratch}/a_dir"
        , (err, created) ->
          return next err if err
          created.should.not.be.ok
          fs.stat ssh, "#{scratch}/a_dir", (err, stat) ->
            return next err if err
            misc.mode.stringify(stat.mode).should.eql '40744'
            next()


