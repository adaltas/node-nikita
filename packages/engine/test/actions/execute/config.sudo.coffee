
nikita = require '../../../src'
{tags, ssh} = require '../../test'
they = require('ssh2-they').configure ssh

return unless tags.sudo

describe 'actions.execute.config.sudo', ->

  they 'execute.assert', ({ssh}) ->
    nikita
      ssh: ssh
    , ->
      @execute.assert
        cmd: 'whoami'
        content: 'root'
        sudo: true
        trim: true

  they 'readFile without sudo', ({ssh}) ->
    nikita
      ssh: ssh
      sudo: false
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.writeFile
        target: "#{tmpdir}/a_file"
        content: 'hello'
        uid: 0
        gid: 0
        sudo: true
      @fs.chown
        target: "#{tmpdir}/a_file"
        uid: 0
        gid: 0
        sudo: true
      @fs.chmod
        target: "#{tmpdir}/a_file"
        mode: 0o600
        sudo: true
      # Note, we are testing EACCESS error because it is impossible to do it
      # without sudo inside fs.readFile
      @fs.readFile
        target: "#{tmpdir}/a_file"
        encoding: 'ascii'
      .should.be.rejectedWith
        message: "NIKITA_FS_CRS_TARGET_EACCES: fail to read a file because permission was denied, location is \"#{tmpdir}/a_file\"."
        errno: -13
        code: 'NIKITA_FS_CRS_TARGET_EACCES'
        syscall: 'open'
        path: "#{tmpdir}/a_file"

  they 'readFile with sudo', ({ssh}) ->
    nikita
      ssh: ssh
      sudo: false
      tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @fs.writeFile
        target: "#{tmpdir}/a_file"
        content: 'hello'
        uid: 0
        gid: 0
        sudo: true
      @fs.chown
        target: "#{tmpdir}/a_file"
        uid: 0
        gid: 0
        sudo: true
      @fs.chmod
        target: "#{tmpdir}/a_file"
        mode: 0o600
        sudo: true
      @fs.readFile
        target: "#{tmpdir}/a_file"
        encoding: 'ascii'
        sudo: true
      .should.be.resolvedWith 'hello'

  they 'writeFile', ({ssh}) ->
    nikita
      ssh: ssh
      tmpdir: true
    , ({metadata: {tmpdir}})->
      await @fs.mkdir
        target: "#{tmpdir}/a_dir"
      await @fs.chown
        target: "#{tmpdir}/a_dir"
        uid: 0
        gid: 0
        sudo: true
      @fs.writeFile
        target: "#{tmpdir}/a_dir/a_file"
        content: 'some content'
        sudo: true
      @fs.readFile
        target: "#{tmpdir}/a_dir/a_file"
        sudo: true
      .should.resolvedWith 'some content'
      @fs.unlink
        target: "#{tmpdir}/a_dir/a_file"
        sudo: true
    
