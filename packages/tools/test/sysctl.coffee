
nikita = require '@nikitajs/engine/src'
{tags, ssh} = require './test'
they = require('ssh2-they').configure ssh

return unless tags.posix

describe 'tools.sysctl', ->

  they 'Write properties', ({ssh}) ->
    nikita
      ssh: ssh
    .tools.sysctl
      target: "#{tmpdir}/sysctl.conf"
      properties:
        'vm.swappiness': 10
        'vm.overcommit_memory': 1
      load: false
    , (err, {status}) ->
      status.should.be.true() unless err
    .tools.sysctl
      target: "#{tmpdir}/sysctl.conf"
      properties:
        'vm.swappiness': 10
        'vm.overcommit_memory': 1
    , (err, {status}) ->
      status.should.be.false() unless err
    .fs.assert
      target: "#{tmpdir}/sysctl.conf"
      content: """
      vm.swappiness = 10
      vm.overcommit_memory = 1
      """
  
  they 'Overwrite properties by default', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{tmpdir}/sysctl.conf"
      content: """
      vm.swappiness = 10
      vm.overcommit_memory = 1
      """
    .tools.sysctl
      target: "#{tmpdir}/sysctl.conf"
      properties:
        'vm.swappiness': 1
      load: false
    , (err, {status}) ->
      status.should.be.true() unless err
    .fs.assert
      target: "#{tmpdir}/sysctl.conf"
      content: """
      vm.swappiness = 1
      """

  they 'Merge properties', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{tmpdir}/sysctl.conf"
      content: """
      vm.swappiness = 1
      """
    .tools.sysctl
      target: "#{tmpdir}/sysctl.conf"
      properties:
        'vm.swappiness': 10
      merge: true
      load: false
    , (err, {status}) ->
      status.should.be.true() unless err
    .tools.sysctl
      target: "#{tmpdir}/sysctl.conf"
      properties:
        'vm.overcommit_memory': 1
      merge: true
      load: false
    , (err, {status}) ->
      status.should.be.true() unless err
    .fs.assert
      target: "#{tmpdir}/sysctl.conf"
      content: """
      vm.swappiness = 10
      vm.overcommit_memory = 1
      """

  they 'Merge properties with file containing empty lines', ({ssh}) ->
    nikita
      ssh: ssh
    .file
      target: "#{tmpdir}/sysctl.conf"
      content: """
      vm.swappiness = 1
      
      """
    .tools.sysctl
      target: "#{tmpdir}/sysctl.conf"
      properties:
        'vm.swappiness': 10
      merge: true
      load: false
    .fs.assert
      target: "#{tmpdir}/sysctl.conf"
      content: """
      vm.swappiness = 10
      
      """

  they 'honors backup option', ({ssh}) ->
    nikita
      ssh: ssh
    .tools.sysctl
      target: "#{tmpdir}/sysctl.conf"
      properties:
        'vm.swappiness': 10
      load: false
      backup: true
    .execute.assert
      bash: true
      cmd: "[[ `ls #{tmpdir}/sysctl.* | wc -l | sed 's/[ ]*//'` == '1' ]]" # sed to strip trailing space
    .tools.sysctl
      target: "#{tmpdir}/sysctl.conf"
      properties:
        'vm.swappiness': 20
      load: false
      backup: true
    .execute.assert
      bash: true
      cmd: "[[ `ls #{tmpdir}/sysctl.* | wc -l | sed 's/[ ]*//'` == '2' ]]"

  describe 'comment', ->

    they 'Not preserved by default', ({ssh}) ->
      nikita
        ssh: ssh
      .file
        target: "#{tmpdir}/sysctl.conf"
        content: """
        # System Kernel Variables
        vm.swappiness = 1
        # User Variables
        """
      .tools.sysctl
        target: "#{tmpdir}/sysctl.conf"
        properties:
          'vm.swappiness': 10
          'vm.overcommit_memory': 1
        merge: true
        load: false
      , (err, {status}) ->
        status.should.be.true() unless err
      .fs.assert
        target: "#{tmpdir}/sysctl.conf"
        content: """
        vm.swappiness = 10
        vm.overcommit_memory = 1
        """

    they 'preserved when enabled', ({ssh}) ->
      nikita
        ssh: ssh
      .file
        target: "#{tmpdir}/sysctl.conf"
        content: """
        # System Kernel Variables
        vm.swappiness = 1
        # User Variables
        """
      .tools.sysctl
        target: "#{tmpdir}/sysctl.conf"
        properties:
          'vm.swappiness': 10
          'vm.overcommit_memory': 1
        merge: true
        comment: true
        load: false
      , (err, {status}) ->
        status.should.be.true() unless err
      .fs.assert
        target: "#{tmpdir}/sysctl.conf"
        content: """
        # System Kernel Variables
        vm.swappiness = 10
        # User Variables
        vm.overcommit_memory = 1
        """

    they 'handle equal sign in comment', ({ssh}) ->
      nikita
        ssh: ssh
      .file
        target: "#{tmpdir}/sysctl.conf"
        content: """
        # Key = Value
        vm.swappiness = 1
        """
      .tools.sysctl
        target: "#{tmpdir}/sysctl.conf"
        properties:
          'vm.swappiness': 10
        merge: true
        comment: true
        load: false
      .fs.assert
        target: "#{tmpdir}/sysctl.conf"
        content: """
        # Key = Value
        vm.swappiness = 10
        """
