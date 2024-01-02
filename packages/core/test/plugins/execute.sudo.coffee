
import nikita from '@nikitajs/core'
import test from '../test.coffee'
import mochaThey from 'mocha-they'
they = mochaThey(test.config)

describe 'plugins.execute.sudo', ->
  return unless test.tags.sudo

  they 'readFile without sudo', ({ssh}) ->
    nikita
      $ssh: ssh
      $sudo: false
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @fs.base.writeFile
        $sudo: true
        target: "#{tmpdir}/a_file"
        content: 'hello'
        uid: 0
        gid: 0
      await @fs.base.chown
        target: "#{tmpdir}/a_file"
        uid: 0
        gid: 0
        $sudo: true
      await @fs.base.chmod
        target: "#{tmpdir}/a_file"
        mode: 0o600
        $sudo: true
      # Note, we are testing EACCESS error because it is impossible to do it
      # without sudo inside fs.readFile
      await @fs.base.readFile
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
      $ssh: ssh
      $sudo: false
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      await @fs.base.writeFile
        $sudo: true
        target: "#{tmpdir}/a_file"
        content: 'hello'
        uid: 0
        gid: 0
      await @fs.base.chown
        $sudo: true
        target: "#{tmpdir}/a_file"
        uid: 0
        gid: 0
      await @fs.base.chmod
        $sudo: true
        target: "#{tmpdir}/a_file"
        mode: 0o600
      await @fs.base.readFile
        $sudo: true
        target: "#{tmpdir}/a_file"
        encoding: 'ascii'
      .should.be.finally.containEql data: 'hello'

  they 'writeFile', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}})->
      await @fs.base.mkdir
        target: "#{tmpdir}/a_dir"
      await @fs.base.chown
        target: "#{tmpdir}/a_dir"
        uid: 0
        gid: 0
        $sudo: true
      await @fs.base.writeFile
        target: "#{tmpdir}/a_dir/a_file"
        content: 'some content'
        $sudo: true
      await @fs.base.readFile
        target: "#{tmpdir}/a_dir/a_file"
        encoding: 'ascii'
        $sudo: true
      .should.resolvedWith data: 'some content'
      await @fs.base.unlink
        target: "#{tmpdir}/a_dir/a_file"
        $sudo: true
      await @fs.base.rmdir
        target: "#{tmpdir}/a_dir"
        $sudo: true
    
