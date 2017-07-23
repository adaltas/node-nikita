
nikita = require '../../src'
they = require 'ssh2-they'
test = require '../test'

describe 'tools.sysctl', ->

  scratch = test.scratch @

  they 'Write properties', (ssh) ->
    nikita
      ssh: ssh
    .tools.sysctl
      target: "#{scratch}/sysctl.conf"
      properties:
        'vm.swappiness': 10
        'vm.overcommit_memory': 1
      load: false
    , (err, status) ->
      status.should.be.true() unless err
    .tools.sysctl
      target: "#{scratch}/sysctl.conf"
      properties:
        'vm.swappiness': 10
        'vm.overcommit_memory': 1
    , (err, status) ->
      status.should.be.false() unless err
    .file.assert
      target: "#{scratch}/sysctl.conf"
      content: """
      vm.swappiness = 10
      vm.overcommit_memory = 1
      """
    .promise()
  
  they 'Overwrite properties by default', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/sysctl.conf"
      content: """
      vm.swappiness = 10
      vm.overcommit_memory = 1
      """
    .tools.sysctl
      target: "#{scratch}/sysctl.conf"
      properties:
        'vm.swappiness': 1
      load: false
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/sysctl.conf"
      content: """
      vm.swappiness = 1
      """
    .promise()

  they 'Merge properties', (ssh) ->
    nikita
      ssh: ssh
    .file
      target: "#{scratch}/sysctl.conf"
      content: """
      vm.swappiness = 1
      """
    .tools.sysctl
      target: "#{scratch}/sysctl.conf"
      properties:
        'vm.swappiness': 10
      merge: true
      load: false
    , (err, status) ->
      status.should.be.true() unless err
    .tools.sysctl
      target: "#{scratch}/sysctl.conf"
      properties:
        'vm.overcommit_memory': 1
      merge: true
      load: false
    , (err, status) ->
      status.should.be.true() unless err
    .file.assert
      target: "#{scratch}/sysctl.conf"
      content: """
      vm.swappiness = 10
      vm.overcommit_memory = 1
      """
    .promise()

  describe 'comment', ->

    they 'Not preserved by default', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/sysctl.conf"
        content: """
        # System Kernel Variables
        vm.swappiness = 1
        # User Variables
        """
      .tools.sysctl
        target: "#{scratch}/sysctl.conf"
        properties:
          'vm.swappiness': 10
          'vm.overcommit_memory': 1
        merge: true
        load: false
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/sysctl.conf"
        content: """
        vm.swappiness = 10
        vm.overcommit_memory = 1
        """
      .promise()

    they 'preserved when enabled', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/sysctl.conf"
        content: """
        # System Kernel Variables
        vm.swappiness = 1
        # User Variables
        """
      .tools.sysctl
        target: "#{scratch}/sysctl.conf"
        properties:
          'vm.swappiness': 10
          'vm.overcommit_memory': 1
        merge: true
        comment: true
        load: false
      , (err, status) ->
        status.should.be.true() unless err
      .file.assert
        target: "#{scratch}/sysctl.conf"
        content: """
        # System Kernel Variables
        vm.swappiness = 10
        # User Variables
        vm.overcommit_memory = 1
        """
      .promise()

    they 'handle equal sign in comment', (ssh) ->
      nikita
        ssh: ssh
      .file
        target: "#{scratch}/sysctl.conf"
        content: """
        # Key = Value
        vm.swappiness = 1
        """
      .tools.sysctl
        target: "#{scratch}/sysctl.conf"
        properties:
          'vm.swappiness': 10
        merge: true
        comment: true
        load: false
      .file.assert
        target: "#{scratch}/sysctl.conf"
        content: """
        # Key = Value
        vm.swappiness = 10
        """
      .promise()
