
nikita = require '../../src'
path = require 'path'
test = require '../test'
they = require 'ssh2-they'

describe 'system.mkdir', ->

  config = test.config()
  scratch = test.scratch @

  they 'as a directory option or as a string', (ssh) ->
    nikita
      ssh: ssh
    .system.mkdir directory: "#{scratch}/a_dir", (err, status) ->
      status.should.be.true()
    .system.mkdir directory: "#{scratch}/a_dir", (err, status) ->
      status.should.be.false()
    .system.mkdir "#{scratch}/b_dir", (err, status) ->
      status.should.be.true()
    .system.mkdir "#{scratch}/b_dir", (err, status) ->
      status.should.be.false()
    .promise()

  they 'should take source if first argument is a string', (ssh) ->
    source = "#{scratch}/a_dir"
    nikita
      ssh: ssh
    .system.mkdir source, (err, status) ->
      status.should.be.true()
    .system.mkdir source, (err, status) ->
      status.should.be.false()
    .promise()
  
  they 'should create dir recursively', (ssh) ->
    nikita
      ssh: ssh
    .system.mkdir
      directory: "#{scratch}/a_parent_dir_1/a_dir"
    , (err, status) ->
      status.should.be.true() unless err
    .system.mkdir
      directory: "#{scratch}/a_parent_dir_2/a_dir/"
    , (err, status) ->
      status.should.be.true() unless err
    .promise()
  
  they 'should create multiple directories', (ssh) ->
    nikita
      ssh: ssh
    .system.mkdir
      ssh: ssh
      target: [
        "#{scratch}/a_parent_dir/a_dir_1"
        "#{scratch}/a_parent_dir/a_dir_2"
      ]
    , (err, status) ->
      status.should.be.true() unless err
    .promise()

  describe 'parent', ->

    they 'true set default permissions', (ssh) ->
      nikita
        ssh: ssh
      .system.mkdir
        target: [
          "#{scratch}/a_parent_dir/a_dir_1"
          "#{scratch}/a_parent_dir/a_dir_2"
        ]
        parent: true
        mode: 0o717
      .file.assert
        target: "#{scratch}/a_parent_dir"
        mode: 0o0717
        not: true
      .promise()

    they 'object set custom permissions', (ssh) ->
      nikita
        ssh: ssh
      .system.mkdir
        target: [
          "#{scratch}/a_parent_dir/a_dir_1"
          "#{scratch}/a_parent_dir/a_dir_2"
        ]
        parent: mode: 0o741
        mode: 0o715
      .file.assert
        target: "#{scratch}/a_parent_dir"
        mode: 0o0741
      .file.assert
        target: "#{scratch}/a_parent_dir/a_dir_1"
        mode: 0o0715
      .promise()

  describe 'exclude', ->
  
    they 'should stop when `exclude` match', (ssh) ->
      source = "#{scratch}/a_parent_dir/a_dir/do_not_create_this"
      nikita
        ssh: ssh
      .system.mkdir
        directory: source
        exclude: /^do/
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: source
        not: true
      .file.assert
        target: path.dirname source
      .promise()

  describe 'cwd', ->

    they 'should honore `cwd` for relative paths', (ssh) ->
      nikita.system.mkdir
        ssh: ssh
        directory: './a_dir'
        cwd: scratch
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/a_dir"
      .promise()

  describe 'mode', ->

    they 'change mode as string', (ssh) ->
      # 40744: 4 for directory, 744 for permissions
      nikita
        ssh: ssh
      .system.mkdir
        directory: "#{scratch}/ssh_dir_string"
        mode: '744'
      .file.assert
        target: "#{scratch}/ssh_dir_string"
        mode: 0o0744
      .promise()

    they 'change mode as octal', (ssh) ->
      # 40744: 4 for directory, 744 for permissions
      nikita
        ssh: ssh
      .system.mkdir
        directory: "#{scratch}/ssh_dir_string"
        mode: 0o744
      .file.assert
        target: "#{scratch}/ssh_dir_string"
        mode: 0o0744
      .promise()

    they 'detect a permission change', (ssh) ->
      # 40744: 4 for directory, 744 for permissions
      nikita
        ssh: ssh
      .system.mkdir
        directory: "#{scratch}/ssh_dir_string"
        mode: 0o744
      .system.mkdir
        directory: "#{scratch}/ssh_dir_string"
        mode: 0o755
      , (err, status) ->
        status.should.be.true()
      .system.mkdir
        directory: "#{scratch}/ssh_dir_string"
        mode: 0o755
      , (err, status) ->
        status.should.be.false()
      .promise()

    they 'dont ovewrite permission', (ssh) ->
      nikita
        ssh: ssh
      .system.mkdir
        directory: "#{scratch}/a_dir"
        mode: 0o744
      .system.mkdir
        directory: "#{scratch}/a_dir"
      , (err, status) ->
        status.should.be.false()
      .file.assert
        target: "#{scratch}/a_dir"
        mode: 0o0744
      .promise()
      
  describe  'ownership', ->

    they 'change owner uid/gid on creation', (ssh) ->
      # 40744: 4 for directory, 744 for permissions
      return if config.disable_system_user
      nikita
        ssh: ssh
      .system.user.remove 'toto'
      .system.group.remove 'toto'
      .system.group 'toto', gid: 1234
      .system.user 'toto', uid: 1234, gid: 1234
      .system.mkdir
        directory: "#{scratch}/ssh_dir_string"
        uid: 1234
        gid: 1234
      .file.assert
        target: "#{scratch}/ssh_dir_string"
        uid: 1234
        gid: 1234
      .promise()
